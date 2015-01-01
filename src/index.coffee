ApiThough = require('./lib/api_through')

process.on 'uncaughtException', (err)->
  console.error('uncaughtException')
  console.error(err)
  console.error(err.stack)

new ApiThough().start()

