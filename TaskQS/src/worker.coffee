events = require 'events'
async = require 'async'
path = require 'path'

Consumer = require './consumer'
Publisher = require './publisher'
QueueLoader = require './queueloader'
Selector = require './selector'
config = require './config/config.json'
utils = require './utils'

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

    queue_loader = new QueueLoader path.resolve __dirname, "config/#{config.sqs.QUEUE_CONFIG}"
    @queue_selector = new Selector queue_loader

    @numIteration = 0

    # Register event listeners
    @on 'message', @_onMessage

    #@on 'task_failed', @on_task_failed
    @on 'release_messages', @_onReleaseMessages

    @on 'err', @_onError

  ###*
  * Infinite Loop to Process Messages from SQS
  ###
  run : ->
    self =@

    if @_checkResourceUsage
      if --self.numIteration < 0
        self._batchQueue = self.queue_selector.get_queue()
        self.numIteration = self._batchQueue.num_iteration

      if self._incompleteMessages.length < config.worker.MAX_INCOMPLETE_MESSAGES
        self.singleLongPoll (err, data)->
          self.emit 'err' , err if err
          process.nextTick ->
            self.run()
      else
        process.nextTick ->
          self.run()


  singleLongPoll: (cb)->
    self = @

    @_consumer.fetch_batch @_batchQueue,
      (err, messages) ->
        if messages.length>0
         self._incompleteMessages.push messages...
         self.emit 'message' , message for message in messages
         self.emit 'release_messages'
        else
          # Change processing queue
          self.numIteration = 0
        cb arguments...


  _checkResourceUsage: ->
    return  true

  _onReleaseMessages:  ->
    self = @
    queue_name = self._batchQueue.name
    messagesToDelete = self._successfulMessages.concat self._failedMessages

    if messagesToDelete.length > 0
      @_consumer.deleteMessages queue_name, messagesToDelete, (err,data) ->
        self.emit 'err' ,err if err


    self._successfulMessages = []
    self._failedMessages = []

  _onMessage: (message) ->

     self = @


     async.waterfall [
       (next) ->
         message.get_body_decoded (body)->
           next null , body
       (data, next) ->
         task_class = utils.importClass data.task_name
         task = new task_class data

         try
           task.launch message.args...
           self._successfulMessages.push message
           next null ,null
         catch err
           permanent_fail = task_class.handle_failure message, err

           if permanent_fail && config.sqs.USED_DEAD_LETTER
             self._permanentMessages.push message

           self._failedMessages.push message

           next err , null
     ], (err, ret) ->
       self.emit 'err' ,err if err

       index = self._incompleteMessages.indexOf message
       self._incompleteMessages.splice index, 1
       self._totalMessagesProcessed +=1


  _onPermanentFail: (message) ->

  _onTaskFail: (message) ->

  _on_shutdown: ->


  _onError: (e)->
    console.log e





