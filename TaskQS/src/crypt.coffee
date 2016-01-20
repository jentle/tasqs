
crypto = require('crypto')
crypt_config = require( './config/config.json').crypt

cipher = crypto.createCipher(crypt_config.ALGORITHM, crypt_config.PASSWORD)
decipher = crypto.createDecipher(crypt_config.ALGORITHM, crypt_config.PASSWORD)

module.exports = class Crypt
  @cipher = cipher
  @decipher = decipher

  @encrypt: (text) ->
    crypted = @cipher.update(text,'utf8','hex')
    crypted += @cipher.final('hex');
    return crypted;

  @decrypt: (text) ->
    dec = @decipher.update(text,'hex','utf8')
    dec += @decipher.final('utf8');
    return dec;


  @encrypt_buff: (buffer) ->
    return Buffer.concat([@cipher.update(buffer),@cipher.final()])

  @decrypt_buff: (buffer) ->
    return Buffer.concat([@decipher.update(buffer) , @decipher.final()])


