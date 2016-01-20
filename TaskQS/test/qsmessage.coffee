should = require 'should'
QsMessage = require '../src/qsmessage'
SQSClient = require '../src/sqsclient'

describe 'QsMessage' ,->
  sqs = new SQSClient
  queue = {}

  before (done)->
    sqs._getQueue 'default', (err, q) ->
      queue = q
      done err

  describe '#create_message',->
    it 'should throw error create a message without queue', ->
      (->
        msg = QsMessage.create_message 'task','001', null, null, 0
      ).should.throw()

    it 'should create a message with queue', ->
      msg = QsMessage.create_message 'task','001', null, queue, 0
      msg.body.should.eql msg.message_params.MessageBody

  describe '#_get_body_encoded',->
    it 'should return encode data', (done) ->
      msg = QsMessage.create_message 'task','001', null, queue, 0
      preencode = msg.body
      msg.get_body_encoded (message)->
        message.body.should.not.eql preencode
        done null




