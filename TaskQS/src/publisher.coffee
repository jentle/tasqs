path = require 'path'
SQSClient = require './sqsclient'
QsMessage = require './qsmessage'
sqs_config = require('./config/config.json').sqs
QueueLoader = require './queueloader'

module.exports = class Publisher extends SQSClient

  publish:(task_class, task_id, payload, retry_num=0, delay_sec=0, cb) ->
    if delay_sec and delay_sec> sqs_config.MAX_TASK_DELAY_SEC
      throw new Error "Invalid task delay,#{delay_sec}s is larger than the setting #{sqs_config.MAX_TASK_DELAY_SEC}"

    queue_loader = new QueueLoader path.resolve __dirname, "config/#{sqs_config.QUEUE_CONFIG}"
    task_queue = queue_loader.get_queue task_class::queue

    @_getQueue task_queue.name, (err, queue)->
      msg = QsMessage.create_message task_class, task_id, payload, queue, retry_num
      queue.write msg, delay_sec, cb


  ###*
   *TODO: IMPLEMENT DEAD LETTER WHEN PERMANENT FAIL
  ###
  publishDeadLetter: (name,messages) ->






