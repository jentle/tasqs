events = require 'events'
async = require 'async'
path = require 'path'

Consumer = require './consumer'
Publisher = require './publisher'
QueueLoader = require './queueloader'
Scheduler = require './scheduler'
config = require './config/config.json'
utils = require './utils'
logger = require './logger'
{
  TimeoutError
} = require './errors'

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

    if @_checkResourceUsage null
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
    memUsage =process.memoryUsage()

    if memUsage.heapTotal < (config.worker.MAX_MEMORY_USAGE * 1024 * 1024)
      return  true
    # If exceed memory
    return false
    process.abort()


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
    @_messagesTimeout = @_batchQueue.visibility_timeout_sec * 1000 + Date.now()
    # Current processing message queue

    async.eachSeries messages, (message, next)->
      self._runMessage message, next
    , (err, results) ->
      self.emit 'err' , err if err
      self._releaseMessages null

      # Clear timeout if all messages complete within VisibilityTimeout
      self._continueRun null

  _runMessage: (message, cb) ->
     return cb new TimeoutError if @._messagesTimeout <= Date.now()

     self = @

     taskClass = null
     async.waterfall [
       (next) ->
         message.get_body_decoded (body)->
           next null , body
       (data, next) ->
         taskClass = utils.importClass data.taskName, data.taskPath
         task = new taskClass data

         nextTimeout = self._messagesTimeout - Date.now()
         nextTimeout = Math.min nextTimeout, taskClass::timeLimit

         # Run the task
         task.launch message.args..., next
     ], (err) ->
       if  err
         permanent_fail = taskClass.handle_failure message, err

         if permanent_fail && config.sqs.USED_DEAD_LETTER
             self._permanentMessages.push message

         self._failedMessages.push message

         index = self._incompleteMessages.indexOf message
         self._incompleteMessages.splice index, 1
       else
         self._successfulMessages.push message

       self._totalMessagesProcessed +=1
       cb null

  _onPermanentFail: (message) ->

  _onTaskFail: (message) ->

  _onShutdown: ->


  _onError: (e)->
    logger.error  e.message





