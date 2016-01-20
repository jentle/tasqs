should = require 'should'
Publisher  = require '../src/publisher'
QsMessage = require '../src/qsmessage'
Task = require '../src/task'
describe 'Publisher', ->
  publisher = new Publisher

  describe '#publish', ->
    it 'should write to sqs', (done) ->
      Task::queue = 'default'
      publisher.publish Task,'001', null, 0, 0, (err, data) ->
        data.MessageId.should.not.eql null
        done err