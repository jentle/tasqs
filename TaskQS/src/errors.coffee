class TimeoutError extends Error
  constructor: ->
    super "Timeout"

errors = {
  TimeoutError
}

module.exports=errors