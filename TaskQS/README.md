# TaskQS

Simple Task Queue on top of Amazon SQS

[Amazon Simple Queue Service (SQS)](https://aws.amazon.com/sqs/?nc1=h_ls) is a fast, reliable, scalable, fully managed message queuing service. SQS makes it simple and cost-effective to decouple the components of a cloud application. You can use SQS to transmit any volume of data, at any level of throughput, without losing messages or requiring other services to be always available.

TaskQS is building with AWS Nodejs SDK and equipped with high throughput and redundancy.

Features :

* Distributed workers 
* Easy configured Task. Task Messasges could store up to 4 days.
* Priority Queue Support (IMPLEMENTED)




## Getting Started

The workflow of TaskQS is quite simple. First , specify your AWS credential in the config.json. TaskQS will create message queues for you.
```json
{
   "aws":{
     "ACCESS_KEY_ID":"",
     "SECRET_ACCESS_KEY":"",
     "REGION":"us-east-1"
   },
   ...
}



```

The TaskQS currently support a queue scheduling based on priority. The priority should be between 10-100. Tasks in high priority queue are not guaranteed first completion than low priority. But they
will have higher probability to be processed first which solves starvation for low priority queues.
```yaml
high_priority:
  name: high_priority
  priority: 100
  batch_size: 10
  visibility_timeout_sec: 60
  long_poll_time_sec: 1
  num_iterations: 10
```

Create your own task by extend the base Task. The class variable "queue" should be specified as the message queue to be published. And the "_runTask" method should be overriden. There should be whatever your task want to do.

```coffeescript
Task = require '../src/task'

class AdditionTask extends Task
  queue : "default"

  _runTask:( a, b, next) ->
     next null, a+b
    
```

Publish your Task to Amazon SQS

```coffeescript
AdditionTask.publish null, 1, 2
    
```

Create a worker to processing task messages. The worker will keep poll messages and processing based on nodejs events.

```coffeescript
Worker = require '../src/worker'

worker = new Worker
worker.run null
```
## Run in docker

TaskQS could run in docker container with easy configuration. The accessKey, secretId, and region is required for your AWS credential.

```
docker run -t -i jentle/tasqs /etc/start-worker <accessKey> <secretId> <region>
```
