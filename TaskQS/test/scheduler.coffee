should = require 'should'
path = require 'path'
_ = require 'lodash'

config = require './config/config.json'
QueueLoader = require '../src/queueloader'
Scheduler = require '../src/scheduler'

describe 'scheduler#getQuue' , ->
  it 'should return queue with high priority which has high probability', ->
    queueLoader = new QueueLoader path.resolve __dirname, "config/#{config.sqs.QUEUE_CONFIG}"
    scheduler = new Scheduler queueLoader
    num = 100
    queues = {}

    while  --num
      queue=scheduler.getQueue null
      queues[queue.name] = 1+ (queues[queue.name] || 0 )

    qList = []
    for name, count of queues
      qList.push
        name :name,
        count : count

    qList.sort (a,b) ->
      return b.count - a.count

    qList[0].name.should.eql queueLoader.getQueues()[0].name

