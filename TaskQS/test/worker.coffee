Worker = require '../src/worker.coffee'

describe 'worker', ->
  worker = new Worker

  describe '#singleLongPoll' ,->
    it 'should callback when message' , (done) ->
      worker.singleLongPoll done