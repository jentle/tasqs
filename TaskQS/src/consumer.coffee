QsMessage = require './qsmessage'
SQSClient = require './sqsclient'

module.exports = class Consumer extends SQSClient

  fetch_batch : ({name, batch_size, visibility_timeout_sec, long_poll_time_sec}, cb) ->
    @_getQueue name, ( err, queue)->
      unless err
        queue.get_messages batch_size, visibility_timeout_sec, long_poll_time_sec, (err, data) ->
          return cb arguments... if err
          qsmessages = []

          if data.Messages
            for message in data.Messages
              {Body, MessageId, ReceiptHandle} = message
              msg= new QsMessage queue, Body, MessageId, ReceiptHandle
              qsmessages.push msg

          cb err, qsmessages

  deleteMessages :  (name, messages, cb) ->
    @_getQueue name, (err, queue) ->
      unless err
        queue.deleteMessagesBatch messages, cb
      cb arguments... if err

  releaseMessages:  (name, messages, cb) ->
    @_getQueue name, (err, queue) ->
      unless err
        messages_params = ( [message,0] for message in messages)
        queue.changeVisibilityTimeoutBatch messages_params, cb
      cb arguments... if err