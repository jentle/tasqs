
module.exports = class Queue
  constructor: (conn, queueUrl) ->
    @connection = conn
    @queueUrl = queueUrl
    @name = @queueUrl.split("/").slice(-1)[0]


  write: (message, delay_sec, cb)->

    self = @
    message.set_delay_sec delay_sec
    .get_body_encoded (msg)->
      self.connection.client.sendMessage msg.message_params ,cb


  get_messages:(  num_messages, visibility_timeout, wait_time_sec, cb)->
    self = @
    options =
      QueueUrl : self.queueUrl,
      AttributeNames: ["All"],
      MaxNumberOfMessages: num_messages,
      WaitTimeSeconds: wait_time_sec,
      VisibilityTimeout: visibility_timeout
    @connection.client.receiveMessage options, cb

  deleteMessagesBatch:(  messages, cb)->
    self = @
    entries = []
    for message in messages
      entries.push
        Id: message.id
        ReceiptHandle: message.receiptHandle

    options =
      Entries : entries
      QueueUrl : self.queueUrl

    @connection.client.deleteMessageBatch options,cb

  changeVisibilityTimeoutBatch:(  messages_params, cb)->
    self = @
    entries = []

    for param in messages_params
      message = param[0]
      value = param[1]
      entries.push
        Id: message.id
        ReceiptHandle: message.receiptHandle
        VisibilityTimeout: value

    options =
      Entries : entries
      QueueUrl : self.queueUrl

    @connection.client.changeMessageVisibilityBatch options,cb






