should = require 'should'
SQSClient = require '../src/sqsclient'

describe 'SQSClient', ->
  sqs = new SQSClient

  before (done) ->
    sqs._get_connection done

  describe '#_getQueue' ,->
    it 'should return or create queue with the queue name' ,(done) ->
      sqs._getQueue 'default', (err, queue)->
        queue.name.should.eql 'default'
        done null

  describe '#_get_all_queues', ->
    it 'should return all the queues in current connection',  ->
      console.log sqs._get_all_queues null
