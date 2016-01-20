should = require 'should'
Task = require '../src/task'
describe 'Task' ,->
  describe '#@publish' , ->
    it 'should publish a task message to sqs' , (done) ->
      Task.publish null, done