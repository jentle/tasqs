Queue = require './queue'
async = require 'async'

module.exports =  class SQSConnection
  constructor: (sqsClient)->
    @queues = {}
    @queueUrls = {}
    @client = sqsClient

  find: (queue_name) ->
    return @queues[queue_name]


  get_queues: (exp="" )->
    re = new RegExp(exp)
    return (q for q_name,q of @queues when re.test(q_name) and  @queues.hasOwnProperty q_name )

  add_queue: (queueUrl) ->
    return if @queueUrls[queueUrl]
    self = @
    q = new Queue self, queueUrl
    @queueUrls[queueUrl] = q.name
    @queues[q.name] = q

  create_queue: (queue_name, cb) ->
    self = @
    async.waterfall [
      (next) ->
        self.client.createQueue
           QueueName: queue_name
        , next
      (data, next) ->
        self.add_queue data.QueueUrl
        next null, self.queues[queue_name]
    ],(err, queue) ->
      cb arguments...
      console.log "Cannot create new queue #{queue_name} to Amazon SQS \n" if err



