
module.exports = class Message

  constructor:( queue, body, id=null, receiptHandle=null) ->
    throw new Error 'No queue specified with message' unless queue
    @queue = queue
    @body = body
    @id = id
    @receiptHandle = receiptHandle

    self = @
    @message_params =
      MessageBody: self.body,
      QueueUrl: self.queue.queueUrl,
      DelaySeconds:null,
      MessageAttributes: null

  get_body_encoded: (cb)->
    return cb @ unless @body

    message_body = JSON.stringify @body
    self = @
    @encode message_body , (encoded_body)->
      self.set_body encoded_body
      cb self
    @

  encode: (value,cb)->

  decode:(cb) ->


  set_body: (body) ->
    @body = body
    @message_params["MessageBody"] = @body
    @

  get_body_decoded:(cb) ->
    @decode cb

  set_delay_sec: (delay_sec) ->
    @message_params["DelaySeconds"] = delay_sec
    @
