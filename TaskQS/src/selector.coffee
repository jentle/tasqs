
module.exports = class Selector
  constructor: (queueloader)->
    @queueloader = queueloader
    @_queues = @queueloader.get_queues()

  get_queue: ->
    return @queueloader.get_queue 'default'