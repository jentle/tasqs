events = require 'events'
async = require 'async'
path = require 'path'
util = require 'util'

Consumer = require './consumer'
Publisher = require './publisher'
QueueLoader = require './queueloader'
Scheduler = require './scheduler'
config = require './config/config.json'
utils = require './utils'
logger = require './logger'

signals = [
  'SIGINT',
  'SIGQUIT',
  'SIGTERM',
]

module.exports = class Worker extends events.EventEmitter
  constructor:->
    @_consumer = new Consumer

    @_publisher = new Publisher

    @_totalMessagesProcessed = 0

    @_incompleteMessages = []
    @_successfulMessages = []
    @_failedMessages = []

    # Push to dead letter when permanent failed
    @_permanentMessages = []
    @_totalMessagesProcessed = 0

    queueLoader = new QueueLoader path.resolve __dirname, "config/#{config.sqs.QUEUE_CONFIG}"
    @queueScheduler = new Scheduler queueLoader

    @numIteration = 0

    # Register event listeners
    @on 'messages', @_onMessages

    @on 'err', @_onError


    @_setupSignals null


  ###*
  * Infinite Loop to Process Messages from SQS
  ###
  run : ->
    self =@

    if @_checkResourceUsage
      if --self.numIteration < 0
        # Current message fetching message queue
        self._batchQueue = self.queueScheduler.getQueue()
        self.numIteration = self._batchQueue.num_iteration


      # Continuous long poll from SQS
      # Ensure more task completed within VisibilityTimeout
      self.singleLongPoll (err, messages)->
        self.emit 'err' , err if err
        if messages and messages.length > 0
          self._timeout = setTimeout ->
            self._continueRun null
          , self._getTimeout null
        else
          self.numIteration = 0
          self._continueRun null

  _continueRun : ->

    clearTimeout @_timeout if @_timeout

    # Delete Failed Messages and Make all incomplete  messages visible to other workers
    self = @

    logger.info "Total messages processed #{self._totalMessagesProcessed}"
    process.nextTick ->
      self.run()

  singleLongPoll: (cb)->
    return cb null, null if @_incompleteMessages.length > 0
    self = @

    @_consumer.fetch_batch @_batchQueue,
      (err, messages) ->
        self.emit 'messages' ,messages if messages and messages.length>0
        cb arguments...


  _checkResourceUsage: ->
    return  true

  _getTimeout: ->
    return 1000 * Math.abs @_batchQueue.visibility_timeout_sec - @_batchQueue.long_poll_time_sec

  _setupSignals : ->
    self = @
    for signal in signals
      process.on signal, () ->
        logger.info "Process met signal #{signal} , aborting..."
        self._releaseMessages null
        process.exit()

  _releaseMessages:   ->
    queueName = @_batchQueue.name
    messagesToDelete = @_successfulMessages.concat @_failedMessages

    if messagesToDelete.length > 0
      @_consumer.deleteMessages queueName, messagesToDelete, ->

    if @_incompleteMessages.length > 0
      # change visibility of incomplete messages
      @_consumer.releaseMessages queueName, @_incompleteMessages, ->

    @_successfulMessages = []
    @_failedMessages = []
    @_incompleteMessages = []

  _onMessages: (messages) ->
    self = @
    @_incompleteMessages.push messages...

    # Current processing message queue
    self._workingQueue = self._batchQueue

    async.eachSeries messages, (message, next)->
      self._runMessage message, next
    , (err, results) ->
      self.emit 'err' , err if err
      self._releaseMessages null

      # Clear timeout if all messages complete within VisibilityTimeout
      self._continueRun null

  _runMessage: (message, cb) ->
     self = @
     @working_message=message
     async.waterfall [
       (next) ->
         message.get_body_decoded (body)->
           next null , body
       (data, next) ->
         task_class = utils.importClass data.taskName, data.taskPath
         task = new task_class data

         try
           task.launch message.args...
           self._successfulMessages.push message
           next null ,null
         catch err
           self.error_message=message

           logger.error "task #{task.id} ,err #{err.message}"
           permanent_fail = task_class.handle_failure message, err

           if permanent_fail && config.sqs.USED_DEAD_LETTER
             self._permanentMessages.push message

           self._failedMessages.push message

           next null , null
     ], (err, ret) ->

       index = self._incompleteMessages.indexOf message
       self._incompleteMessages.splice index, 1
       self._totalMessagesProcessed +=1
       cb arguments...



  _onPermanentFail: (message) ->

  _onTaskFail: (message) ->

  _on_shutdown: ->


  _onError: (e)->
    logger.error  e.message





