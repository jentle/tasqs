should = require 'should'
crypt = require '../src/crypt'

describe 'Crypt', ->
  describe '#encrypt#decrypt',->
    it 'should return the same after encrypt and decrypt', ->
      input = "hello world"
      encoded =  crypt.encrypt input
      output = crypt.decrypt encoded
      output.should.eql input


  describe 'decode', ->
    it 'should return a json' ,->
      crypt.decrypt '4841b4a0b4f1cfae6ee147f3f859253f'