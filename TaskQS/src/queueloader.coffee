yaml = require 'js-yaml'
fs = require 'fs'

class TaskQueue
  constructor:({name, priority,num_iterations, batch_size, long_poll_time_sec, visibility_timeout_sec })->
    @name = name
    @priority = priority
    @num_iteration = num_iterations
    @batch_size = batch_size
    @long_poll_time_sec = long_poll_time_sec
    @visibility_timeout_sec = visibility_timeout_sec

module.exports = class QueueLoader
  _queues = null
  _queues_map = null

  constructor: (config_path) ->
    unless @_queues
      @_queues = @constructor._get_configured_queues config_path

    unless @_queues_map
      @_queues_map = {}
      @_queues_map[q.name] = q for q in @_queues

  get_queue : (queue_name) ->
    return @_queues_map[queue_name]

  get_queues: ->
    return @_queues

  @_get_configured_queues: (file )->
    try
      config_queues = yaml.safeLoad(fs.readFileSync(file, 'utf8'));
      queues =[]
      for queue_name, queue_config of config_queues
        q = new TaskQueue(queue_config)
        queues.push q
      queues.sort (a, b)->
        return b.priority - a.priority
      return queues
    catch e
      console.log e