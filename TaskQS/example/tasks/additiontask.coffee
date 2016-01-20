Task = require '../../src/task'

module.exports = class AdditionTask extends Task
  queue : "default"
  @classPath : __filename

  _runTask:( a, b) ->
    console.log "Addition result #{a+b}"