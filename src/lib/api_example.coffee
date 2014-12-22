module.exports = -> new ApiExample()

mongoose = require('mongoose')

ApiExample = mongoose.model 'ApiExample', new mongoose.Schema
  url:
    type: String
  host:
    type: String
  method:
    type: String
  requestHeaders:
    type: Object
  responseHeaders:
    type: Object
  responseBody:
    type: String
    default: ''

ApiExample.prototype.saveWithErrorLog =   ->
  @save (error)->
    console.log("Failed to save because of error", error) if error