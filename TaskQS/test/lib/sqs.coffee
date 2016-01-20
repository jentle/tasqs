should = require 'should'
sqs = require '../../src/lib/sqs'
config = require '../config/config.json'

describe 'SQS#connect', ->
  it 'should failed to connect to Amazon SQS with a empty region' ,  (done)->
      sqs.connect
        region: '',
        accessKeyId:'',
        secretAccessKey:''
      , (err ) ->
          err.should.not.eql null
          err.code.should.eql 'ConfigError'
          err.message.should.eql 'Missing region in config'
          done null


  it 'should connect to Amazon SQS with a connection', (done) ->

    {REGION, ACCESS_KEY_ID, SECRET_ACCESS_KEY} = config.aws

    sqs.connect
        region: REGION,
        accessKeyId:ACCESS_KEY_ID,
        secretAccessKey:SECRET_ACCESS_KEY
      , (err , conn) ->
          done err if err
          conn.should.not.eql null
          done null


