events  = require 'events'
AWS = require 'aws-sdk'
async = require 'async'
wait = require('wait.for')


SQSConnection = require './sqsconnection'
_ = require 'lodash'


module.exports = class SQS extends events.EventEmitter
  constructor: ->
    @client = null

  @connect:({region, accessKeyId, secretAccessKey}, cb) ->

    @client = new AWS.SQS
            region: region,
            accessKeyId: accessKeyId
            secretAccessKey: secretAccessKey

    self = @
    @client.listQueues null,(err, data)->
      return cb arguments... if err
      conn = new SQSConnection self.client
      conn.add_queue q_name for q_name in data.QueueUrls
      cb null, conn






