path = require 'path'

getTimestamp = ->
  return Date.now()

importClass = (class_path)->
  return require path.resolve(__dirname, class_path)

getClassPath = (file) ->
  return path.relative __dirname,file


utils ={
  getTimestamp,
  importClass,
  getClassPath
}

module.exports = utils