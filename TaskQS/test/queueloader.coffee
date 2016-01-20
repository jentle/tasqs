should = require 'should'
path = require 'path'

QueueLoader = require '../src/queueloader'


describe 'QueueLoader', ->
  describe '#constructor' ,->
    it 'should return a obj with config queues', ->
      qloader = new QueueLoader path.resolve __dirname,'config/queue_config.yaml'
      queue = qloader.get_queue 'default'
      queue.name.should.eql = 'default'

  describe '#_get_configured_queues',->
    it 'should return queues from config files', ->
      queues = QueueLoader._get_configured_queues path.resolve __dirname,'config/queue_config.yaml'
