module.exports = -> new ApiExample()

mongoose = require('mongoose')
url = require('url')
_u = require('underscore')

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
      index: true
    resource:
      type: String
      index: true
    url:
      type: String
    query:
      type: Object
    host:
      type: String
      index: true
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
  unless @query
    @query = @parsedUrl().query

  unless @version
    @version = @guessedVersion()

  unless @resource
    @resource = @guessedResource()

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

ApiExample.prototype.parsedUrl = ->
  url.parse(@url, true)

ApiExample.prototype.guessedResource = ->
  parts = @parsedUrl().pathname.split('/').reverse()
  _u.find parts, (part) -> part.match(/^[^\d].*$/)


