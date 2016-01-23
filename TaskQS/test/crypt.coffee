should = require 'should'
crypt = require '../src/crypt'

describe 'Crypt', ->
  describe '#encrypt#decrypt',->
    it 'should return the same after encrypt and decrypt', ->
      input = "hello world"
      encoded =  crypt.encrypt input
      output = crypt.decrypt encoded
      output.should.eql input
