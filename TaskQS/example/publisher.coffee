tasks  = require './tasks/tasks'

setInterval ->
  tasks.HighPriorityTask.publish null, 1, 2 , ->
, 3000

setTimeout ->
  console.log "end"
, 1000000


