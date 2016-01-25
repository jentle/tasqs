Task = require '../../src/task'

class HighPriorityTask extends Task
  queue: 'high_priority'

  _runTask:( a, b, next) ->
    next null, a+b

class HighPriorityErrorTask extends Task
  queue: 'high_priority'

  _runTask:( a, b, next) ->
    next new Error "Addition result #{a+b}"


class DefaultPriorityTask extends Task
  queue: 'default'

  _runTask:( a, b, next) ->
    next null, a+b

class DefaultPriorityErrorTask extends Task
  queue: 'default'

  _runTask:( a, b, next) ->
    next new Error "Addition result #{a+b}"

class LowPriorityTask extends Task
  queue: 'low_priority'

  _runTask:( a, b, next) ->
    next null, a+b

class LowPriorityErrorTask extends Task
  queue: 'low_priority'

  _runTask:( a, b, next) ->
    next new Error "Addition result #{a+b}"

class TimeoutTask extends Task
  timeLimit:1000
  queue: "default"

  _runTask: ( next)->
    setTimeout ->
      next new Error "Timeout"
    , 2000


tasks = {
  HighPriorityTask,
  HighPriorityErrorTask,
  DefaultPriorityTask,
  DefaultPriorityErrorTask,
  LowPriorityErrorTask,
  LowPriorityTask,
  TimeoutTask

}

module.exports = tasks


