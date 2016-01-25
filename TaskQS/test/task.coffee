should = require 'should'
Task = require '../src/task'

describe 'Task' ,->
  describe '#@publish' , ->
    it 'should throw error if task not specified queue name when publish a task message to sqs' , (done) ->

