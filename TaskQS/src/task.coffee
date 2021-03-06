uuid = require 'node-uuid'
path = require 'path'
async = require 'async'

_ = require 'lodash'
Publisher = require './publisher'
config = require './config/config.json'
logger = require './logger'

module.exports= class Task
  maxRetries : 4

  retryDelayMultiple : config.sqs.RETRY_DELAY_MULTIPLE_SEC
  # Specify the queue to push , should be override in subclass
  # Should be override
  queue : null

  # Task Timeout Limit in milliseconds
  timeLimit : 60000

  constructor: (message_body)->
    message = message_body

    {id, payload, _publisher_data, retryNum, _enqueued_time} = message

    @id = id
    @payload = payload
    @_publisher_data = _publisher_data
    @retryNum = retryNum
    @_enqueuedTime = _enqueued_time

    # For Task Tracing
    @_startTime = null
    @_endTime = null
    @_dequeuedTime = null

    @_dequeued null



  @publish: (app_data, args..., cb=->) ->
    @classpath = @_getClasspath module, @name
    task_id = @_get_task_id @name
    payload =
      args: args
    payload.app_data = app_data if app_data

    publisher = new Publisher
    publisher.publish @, task_id, payload, 0,0,  cb

  @_get_task_id: ->
    return "#{ @name}-#{uuid.v1()}"

  ###*
  *
  *
  ###
  @_getClasspath : (mod, name)->
    self = @
    parents =[]
    if (typeof mod.parent )== 'Array'
      parents.push mod.parent...
    else
      parents.push mod.parent
    for p in parents
      return p.filename if (path.basename p.filename ) == name.toLowerCase()
      for sub, obj of p.exports
        return p.filename if sub == name

  @_getDelaySec: (retryNum) ->
    return Math.min (1<<retryNum )* @::retryDelayMultiple , config.sqs.MAX_TASK_DELAY_SEC

  @handle_failure: (message, err)->

    allowed_retries = @::maxRetries

    if not allowed_retries or allowed_retries <=0
      return true

    if allowed_retries <= message.retryNum
      return true

    @classpath = @_getClasspath module, @name

    # Republish failed message if not permanent failed
    publisher = new Publisher
    {taskId, payload, retryNum } = message
    delaySec = @_getDelaySec retryNum
    publisher.publish @, taskId, payload, retryNum+1, delaySec

    return false

  launch : (args..., cb)->
    self = @
    async.series [
      (next)->
        self._checkEnv next
      (next) ->
        self._preRun args... , next
      (next) ->
        try
          self._runTask args..., next
        catch e
          next e
      (next) ->
        self._postRun args..., next
    ], (err)->
      logger.error "task #{self.id} failed ,err #{err.message}" if err
      cb arguments...

  _checkEnv :(next)->
    next null

  _preRun: (args..., next) ->
    @_startTime = Date.now null
    next null

  _runTask: (args...,next)->
    next new Error "Not Implemented"

  _postRun: (args..., next) ->
    @_endTime = Date.now null
    next null

  _dequeued :()->
    @_dequeuedTime = Date.now null

    taskMeta =
      queue: @queue,
      id: @id,
      dequeuedTime: @_dequeuedTime - @_enqueuedTime,
      currentRetry: @retryNum

    logger.data taskMeta