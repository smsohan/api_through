module.exports = -> new ApiExample()

mongoose = require('mongoose')

#starts with v followed by numbers and . (dot)
#example application/vnd.github.v3+json => v3
#example application/vnd.github.v3.2+json => v3.2
#example application/vnd.github.v3.2-pre+json => v3.2
VERSION_IN_HEADER = /v[\d.]+/

#starts with v followed by a number, until the next / (slash)
#example /v2/x => v2
#example /v2.1/x => v2.1
#example /v2.1-pre/x => v2.1-pre
#example /v2pre/x => v2pre
#example /vowels => null
VERSION_IN_URL = /\/(v\d[^\/]*)/

ApiExample = mongoose.model 'ApiExample', new mongoose.Schema
    description:
      type: String
    version:
      type: String
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
  ,
    collection: 'api_examples'

ApiExample.schema.pre 'save', (callback) ->
  unless @version
    @version = @guessedVersion()

  callback()

ApiExample.prototype.saveWithErrorLog =   ->
  @save (error)->
    console.log("Failed to save because of error", error) if error

ApiExample.prototype.guessedVersion = ->
  @guessedVersionFromURL() || @guessedVersionAcceptHeader()

ApiExample.prototype.guessedVersionFromURL = ->
  return null unless @url?
  @url.match(VERSION_IN_URL)
  RegExp.$1

ApiExample.prototype.guessedVersionAcceptHeader = ->
  return null unless @requestHeaders['accept']?
  @requestHeaders['accept'].match(VERSION_IN_HEADER)



