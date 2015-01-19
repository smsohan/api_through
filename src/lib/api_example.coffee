# module.exports = -> new ApiExample()

mongoose = require('mongoose')
url = require('url')
_u = require('underscore')
crypto = require('crypto')

VERSION_IN_HEADER = /v(\d|\.\d)+/
VERSION_IN_URL = /\/(v\d[^\/]*)/

CUSTOM_HEADERS =
  DESC_HEADER: "x-spy-rest-desc"
  VERSION_HEADER: "x-spy-rest-version"
  RESOURCE_HEADER: "x-spy-rest-resource"
  API_TOKEN_HEADER: "x-spy-rest-api-token"

ApiExamplesSchema = new mongoose.Schema
    description:
      type: String
    version:
      type: String
      default: 'Default'
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
    strippedResponseBody:
      type: String
      default: ''
    recordedAt:
      type: Date
      default: -> new Date()
    fullURL:
      type: String
      default: ''
    digest:
      type: String
      default: ''
    requiresAuth:
      type: Boolean
      default: false
    api_token:
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
  @version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || @guessedVersion() || 'Default'
  @resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] ||@guessedResource()
  @action = @computedAction()
  @query = @parsedUrl().query

  @digest = @computeDigest()
  @api_token = @requestHeaders[CUSTOM_HEADERS.API_TOKEN_HEADER]
  @filterAuthHeaders()

ApiExample.prototype.stripResponseBody = ->
  StrippedObject = require('./stripped_object')
  strippedObject = new StrippedObject()
  try
    @strippedResponseBody = JSON.stringify(strippedObject.strip(JSON.parse(@responseBody)))
  catch
    @strippedResponseBody = @responseBody

ApiExample.prototype.saveWithErrorLog =   ->
  @save (error)->
    console.error("Failed to save because of error", error) if error

ApiExample.prototype.guessedVersion = ->
  @guessedVersionFromURL() || @guessedVersionAcceptHeader()

ApiExample.prototype.guessedVersionFromURL = ->
  return null unless @url?

  RegExp.$1 if @url.match(VERSION_IN_URL)


ApiExample.prototype.guessedVersionAcceptHeader = ->
  return null unless @requestHeaders['accept']?
  matches = @requestHeaders['accept'].match(VERSION_IN_HEADER)
  matches[0] if matches?

ApiExample.prototype.parsedUrl = ->
  url.parse(@url, true)

ApiExample.prototype.guessedResource = ->
  parts = @parsedUrl().pathname.split('/').reverse()
  possibleResource = _u.find parts, (part) -> part.match(/^[^\d].*$/)
  possibleResource.split('.')[0] if possibleResource?

ApiExample.prototype.computedAction = ->
  "#{@http_method} #{@parsedUrl().pathname}"

ApiExample.prototype.setFullUrl = (isSSL, hostPort)->
  scheme = if isSSL then "https" else "http"
  host = hostPort.host

  if scheme == "http" && hostPort.port != 80
    port = ":" + hostPort.port
  else if scheme == "https" && hostPort.port != 443
    port = ":" + hostPort.port
  else
    port = ''

  @fullURL = "#{scheme}://#{host}#{port}#{@url}"

ApiExample.prototype.filterAuthHeaders = ->
  @requestHeaders = _u.reduce @requestHeaders, (filteredHeaders, value, key) =>
      if key == 'authorization'
        filteredHeaders[key] = 'FILTERED'
        @requiresAuth = true
      else
        filteredHeaders[key] = value

      filteredHeaders
    ,
      {}



ApiExample.prototype.computeDigest = ->
  text = "__VERSION__#{@version}__RESOURCE__#{@resource}__URL__#{@url}__DESC__#{@description}"
  hash = crypto.createHash('sha')
  console.log("digest for text #{text}")
  hash.update(text)
  hash.digest('base64')

module.exports = ApiExample



