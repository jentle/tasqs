uuid = require 'node-uuid'
_ = require 'lodash'
Publisher = require './publisher'
config = require './config/config.json'

module.exports= class Task
  maxRetries : 4

  retryDelayMultiple : config.sqs.RETRY_DELAY_MULTIPLE_SEC
  # Specify the queue to push , should be override in subclass
  # Should be override
  queue : null

  constructor: (message_body)->
    message = message_body

    {id, task_name, payload, _publisher_data, retry_num, _enqueued_time} = message
    @id = id
    @task_name = task_name
    @payload = payload
    @_publisher_data = _publisher_data
    @retry_num = retry_num
    @_enqueued_time = _enqueued_time

    # For Task Tracing
    @_startTime = null
    @_endTime = null
    @_dequeuedTime = null

    @_dequeued null

  @publish: (app_data, args..., cb) ->

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
  @_getClassPath : (name)->
    self = @
    mod = module
    name = name.toLowerCase()
    for child in mod.parent
      return child.filename if child.filename.match("/#{name}.coffee$")


  @_getDelaySec: (retryNum) ->
    return Math.min 1<<retryNum * @::retryDelayMultiple , config.sqs.MAX_TASK_DELAY_SEC

  @handle_failure: (message, err)->
    allowed_retries = @::maxRetries

    if not allowed_retries or allowed_retries <=0
      return true

    if allowed_retries <= message.retry_num
      return true

    # Republish failed message if not permanent failed
    publisher = new Publisher
    {taskId, payload, retryNum } = message
    delaySec = @_getDelaySec retryNum

    publisher.publish @, taskId, payload, retryNum+1, delaySec

    return false

  launch : (args...)->
    @_checkEnv null
    @_preRun args...

    try
      @_runTask args...
    catch  e
      throw e

    @_postRun args...

  _checkEnv :()->

  _preRun: (args...) ->
    @_startTime = Date.now null
  _runTask: (args...)->

  _postRun: (args...) ->
    @_endTime = Date.now null

  _dequeued :()->
    @_dequeuedTime = Date.now null