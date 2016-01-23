# Implement a Lottery Scheduling
# https://en.wikipedia.org/wiki/Lottery_scheduling
# Lottery Scheduling solves the problem of Starvation.
# Tasks in High priority Queue has large chance to be processed first
# Tasks in Low Priority Queue also has chance to be processed without waiting too long

module.exports = class Selector
  constructor: (queueloader)->
    @queueloader = queueloader
    @_queues = @queueloader.getQueues()

  _lottery : (queues) ->

    tickets = {}
    totalTickets = 0

    for queue in queues
      # Queue priority should be within 1 to 100.
      if queue.priority < 1 or queue.priority > 100
        continue

      priority = queue.priority
      low = totalTickets
      totalTickets += priority
      high = totalTickets
      tickets[queue.name] = [low, high]

    try
      number = Math.random()* totalTickets
      for queue in queues
        return queue if number >= tickets[queue.name][0] and number < tickets[queue.name][1]
    catch e
      return null
    # Something wrong happens
    return null

  getQueue: ->
    candidates = [@_queues...]

    return @_lottery candidates