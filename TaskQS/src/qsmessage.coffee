zlib = require 'zlib'
Message = require './lib/message'
crypt = require './crypt'
config = require './config/config.json'
{getTimestamp, getClassPath} = require './utils'


module.exports = class QsMessage extends Message

  @create_message: ( task_class, task_id, payload,
                    queue, current_retry_num=0) ->
    message_body =
      id: task_id,
      task_name:"#{getClassPath task_class.classPath}",
      payload: payload,
      _enqueued_time: getTimestamp null,
      _publisher_data: '',
      retry_num : current_retry_num

    return new QsMessage queue, message_body

  encode: (value,cb)->
    zlib.deflate value, (err, buffer) ->
      if not err
        # buffer = crypt.encode_buff buffer
        cb buffer.toString('base64')

  decode: (cb)->
    # @body = crypt.decode_buff @body
    buf = new Buffer(@body, 'base64')

    self = @
    zlib.unzip buf, (err, buffer) ->
      if not err
        message_body = JSON.parse buffer.toString()
        self.set_body message_body
        self.args = message_body.payload.args
        self.payload = message_body.payload
        self.taskId = message_body.id
        self.retryNum  = message_body.retryNum

        cb message_body
    @


