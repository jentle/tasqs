winston = require 'winston'
fs = require 'fs'
path = require 'path'

config = {
  levels: {
    error: 0,
    debug: 1,
    warn: 2,
    data: 3,
    info: 4,
    verbose: 5,
    silly: 6
  },
  colors: {
    error: 'red',
    debug: 'blue',
    warn: 'yellow',
    data: 'grey',
    info: 'green',
    verbose: 'cyan',
    silly: 'magenta'
  }
};

logDir = path.resolve __dirname, "../logs"
logFile = path.resolve __dirname, "../logs/TaskQS.log"

dataDir = path.resolve __dirname, "../data"
dataFile = path.resolve __dirname, "../data/TaskQS.data"

if not fs.existsSync logDir
  fs.mkdirSync logDir


if not fs.existsSync dataDir
  fs.mkdirSync dataDir

module.exports = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({
      colorize: true,
    }),
    new (winston.transports.File)({
      filename: dataFile,
      level:"data"
    })
  ],
  levels: config.levels,
  colors: config.colors
});
