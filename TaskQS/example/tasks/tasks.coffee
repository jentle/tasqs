Task = require '../../src/task'

class AdditionTask extends Task
  queue : "default"

  _runTask:( a, b) ->
    throw new Error "Addition result #{a+b}"

class HighPriorityTask extends Task
  queue: 'high_priority'

  _runTask:( a, b) ->
    return a+b

class HighPriorityErrorTask extends Task
  queue: 'high_priority'

  _runTask:( a, b) ->
    throw new Error "Addition result #{a+b}"


class DefaultPriorityTask extends Task
  queue: 'default'

  _runTask:( a, b) ->
    return a+b

class DefaultPriorityErrorTask extends Task
  queue: 'default'

  _runTask:( a, b) ->
    throw new Error "Addition result #{a+b}"

class LowPriorityTask extends Task
  queue: 'low_priority'

  _runTask:( a, b) ->
    return a+b

class LowPriorityErrorTask extends Task
  queue: 'low_priority'

  _runTask:( a, b) ->
    throw new Error "Addition result #{a+b}"



tasks = {
  AdditionTask,
  HighPriorityTask,
  HighPriorityErrorTask,
  DefaultPriorityTask,
  DefaultPriorityErrorTask,
  LowPriorityErrorTask,
  LowPriorityTask

}

module.exports = tasks


