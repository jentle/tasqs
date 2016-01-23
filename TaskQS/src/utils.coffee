path = require 'path'

getTimestamp = ->
  return Date.now()

importClass = (className, classPath)->
  mod =  require path.resolve(__dirname, classPath)
  return mod if mod.name == className
  return  mod[className]

getClassPath = (file) ->
  return path.relative __dirname,file


utils ={
  getTimestamp,
  importClass,
  getClassPath
}

module.exports = utils