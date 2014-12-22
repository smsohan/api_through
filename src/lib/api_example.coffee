module.exports = -> new ApiExample()

mongoose = require('mongoose')

ApiExample = mongoose.model 'ApiExample', new mongoose.Schema
    collection: 'api_examples'
  ,
    url:
      type: String
    host:
      type: String
    method:
      type: String
    requestBody:
      type: String
      default: ''
    requestHeaders:
      type: Object
    statusCode:
      type: Number
    responseHeaders:
      type: Object
    responseBody:
      type: String
      default: ''

ApiExample.prototype.saveWithErrorLog =   ->
  @save (error)->
    console.log("Failed to save because of error", error) if error