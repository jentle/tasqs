async = require 'async'
config = require './config/config.json'
sqs = require './lib/sqs'


module.exports = class SQSClient
  _connections : {}
  _queues: {}

  constructor: ->
    throw new Error 'Amazon credential not provided' if not config.aws

  _get_connection: (cb)->
    {REGION, ACCESS_KEY_ID, SECRET_ACCESS_KEY} = config.aws
    @conn_str = [REGION, ACCESS_KEY_ID, SECRET_ACCESS_KEY].join('%')
    @_connection = @_connections[@conn_str]

    return cb @_connection if @_connection
    self = @
    sqs.connect
        region: REGION,
        accessKeyId: ACCESS_KEY_ID,
        secretAccessKey: SECRET_ACCESS_KEY
        , (err, conn) ->
          unless err
            self._connections[self.conn_str] = conn
            self._connection = conn
          cb arguments...
    @

  _getQueue: (queue_name, cb) ->
    self = @
    return cb null, self._queues[queue_name] if self._queues[queue_name]

    async.waterfall [
      (next) ->
        if not self._connection
          self._get_connection next
        else
          next null, self._connection
      (data, next) ->
        queue = self._connection.find(queue_name)

        next null, queue if queue
        # Create a new queue if not exists
        self._connection.create_queue queue_name , next unless queue
    ], (err, ret) ->
      self._queues[queue_name] = ret unless err
      cb arguments...

  _get_all_queues: ->
    return @_connection.get_queues()
