module.exports = -> new ApiExample()

mongoose = require('mongoose')
url = require('url')
_u = require('underscore')

VERSION_IN_HEADER = /v[\d\.]+/
VERSION_IN_URL = /\/(v\d[^\/]*)/


CUSTOM_HEADERS =
  DESC_HEADER: "x-api-through-desc"
  VERSION_HEADER: "x-api-through-version"
  RESOURCE_HEADER: "x-api-through-resource"


ApiExamplesSchema = new mongoose.Schema
    description:
      type: String
    version:
      type: String
    resource:
      type: String
    action:
      type: String
    url:
      type: String
    query:
      type: Object
    host:
      type: String
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

ApiExamplesSchema.index
  host: 1
  version: 1
  resource: 1
  action: 1

ApiExample = mongoose.model 'ApiExample', ApiExamplesSchema

ApiExample.prototype.populateFromRequest = (request)->
  @host = request.headers.host
  @url = request.url
  @http_method = request.method

  @requestHeaders = request.headers

  @description = request.headers[CUSTOM_HEADERS.DESC_HEADER]
  @version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || @guessedVersion()
  @resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] ||@guessedResource()
  @action = @computedAction()
  @query = @parsedUrl().query

ApiExample.prototype.saveWithErrorLog =   ->
  @save (error)->
    console.log("Failed to save because of error", error) if error

ApiExample.prototype.guessedVersion = ->
  console.log "@guessedVersionFromURL() = #{@guessedVersionFromURL()}"
  console.log "@guessedVersionAcceptHeader() = #{@guessedVersionAcceptHeader()}"
  @guessedVersionFromURL() || @guessedVersionAcceptHeader()

ApiExample.prototype.guessedVersionFromURL = ->
  return null unless @url?

  console.log("@url = #{@url}")
  RegExp.$1 if @url.match(VERSION_IN_URL)


ApiExample.prototype.guessedVersionAcceptHeader = ->
  return null unless @requestHeaders['accept']?
  @requestHeaders['accept'].match(VERSION_IN_HEADER)

ApiExample.prototype.parsedUrl = ->
  url.parse(@url, true)

ApiExample.prototype.guessedResource = ->
  parts = @parsedUrl().pathname.split('/').reverse()
  possibleResource = _u.find parts, (part) -> part.match(/^[^\d].*$/)
  possibleResource.split('.')[0] if possibleResource?

ApiExample.prototype.computedAction = ->
  "#{@http_method} #{@parsedUrl().pathname}"



