tasks  = require './tasks/tasks'

{
  HighPriorityTask,
  HighPriorityErrorTask,
  DefaultPriorityTask,
  DefaultPriorityErrorTask,
  LowPriorityErrorTask,
  LowPriorityTask

} = tasks

setInterval ->
  HighPriorityTask.publish null, 1, 2 , ->
, 1000

setInterval ->
  DefaultPriorityTask.publish null, 1, 2 , ->
, 1000

setInterval ->
  LowPriorityTask.publish null, 1, 2 , ->
, 1000

setInterval ->
  HighPriorityErrorTask.publish null, 1, 2 , ->
, 1000

setInterval ->
  DefaultPriorityErrorTask.publish null, 1, 2 , ->
, 1000

setInterval ->
  LowPriorityErrorTask.publish null, 1, 2 , ->
, 1000


setTimeout ->
  console.log "end"
, 1000000


