Task = require '../../src/task'

class AdditionTask extends Task
  queue : "default"
  @classPath : __filename

  _runTask:( a, b) ->
    throw new Error "Addition result #{a+b}"

tasks = {
  AdditionTask
}

module.exports = tasks


