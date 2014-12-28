module.exports = -> new ApiExample()

mongoose = require('mongoose')
ApiHost = require('./api_host')
url = require('url')
_u = require('underscore')

VERSION_IN_HEADER = /v[\d.]+/
VERSION_IN_URL = /\/(v\d[^\/]*)/


CUSTOM_HEADERS =
  DESC_HEADER: "x-api-through-desc"
  VERSION_HEADER: "x-api-through-version"
  RESOURCE_HEADER: "x-api-through-resource"

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
    http_method:
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
  upsertData =
    name: this.host

  ApiHost.update upsertData, upsertData, {upsert: true}, (error)->
    console.log("Failed to upsert host due to #{error}") if error?

  callback()

ApiExample.prototype.populateFromRequest = (request)->
  @host = request.headers.host
  @url = request.url
  @http_method = request.method

  @requestHeaders = request.headers

  @description = request.headers[CUSTOM_HEADERS.DESC_HEADER]
  @version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || @guessedVersion()
  @resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] ||@guessedResource()

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
  possibleResource = _u.find parts, (part) -> part.match(/^[^\d].*$/)
  possibleResource.split('.')[0] if possibleResource?


