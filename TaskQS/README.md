# TaskQS

Simple Task Queue on top of Amazon SQS

[Amazon Simple Queue Service (SQS)](https://aws.amazon.com/sqs/?nc1=h_ls) is a fast, reliable, scalable, fully managed message queuing service. SQS makes it simple and cost-effective to decouple the components of a cloud application. You can use SQS to transmit any volume of data, at any level of throughput, without losing messages or requiring other services to be always available.

TaskQS is building with AWS Nodejs SDK and equipped iwth high throughoutput and redundancy.

Features :

* Distributed workers 
* Easy configured Task. Task Messasges could store up to 4 days.
* Priority Queue Support ( NOT IMPLEMENTED)




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
Create your own task by extend the base Task. The class variable "queue" should be specified as the message queue to be published. And the "_runTask" method is whatever your task want to do.

```coffeescript
Task = require '../src/task'

class AdditionTask extends Task
  queue : "default"

  _runTask:( a, b) ->
    console.log "Addition result #{a+b}"
    
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
```
docker pull jentle/tasqs
docker run -t -i jentle/tasqs:0.10 ~/start-worker <accessKey> <secretId> [region]
```
