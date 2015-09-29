# module.exports = -> new ApiExample()

mongoose = require('mongoose')
url = require('url')
_u = require('underscore')
crypto = require('crypto')
validator = require('validator')
inflector = require('i')()

VERSION_IN_HEADER = /v(\d|\.\d)+/
VERSION_IN_URL = /\/(v\d[^\/]*)/

CUSTOM_HEADERS =
  DESC_HEADER: "x-spy-rest-desc"
  VERSION_HEADER: "x-spy-rest-version"
  RESOURCE_HEADER: "x-spy-rest-resource"
  API_TOKEN_HEADER: "x-spy-rest-api-token"
  HOST_HEADER: 'x-spy-rest-host'
  NO_STRIP_HEADER: 'x-spy-rest-no-strip'

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
    templatedURL:
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
    apiToken:
      type: String
      default: ''
    userId:
      type: mongoose.Schema.Types.ObjectId
      default: null
  ,
    collection: 'api_examples'

ApiExamplesSchema.index
  host: 1
  version: 1
  resource: 1
  action: 1

ApiExample = mongoose.model 'ApiExample', ApiExamplesSchema

ApiExample.prototype.populateFromRequest = (request)->
  @host = request.headers[CUSTOM_HEADERS.HOST_HEADER] || request.headers.host
  @url = @filteredUrl(request.url)
  @http_method = request.method

  @requestHeaders = request.headers

  @description = request.headers[CUSTOM_HEADERS.DESC_HEADER]
  @version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || @guessedVersion() || 'Default'
  @resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] ||@guessedResource()
  @query = @parsedUrl().query

  @apiToken = @requestHeaders[CUSTOM_HEADERS.API_TOKEN_HEADER]
  @filterAuthHeaders()
  @templatizeURL()
  @action = @computedAction()
  @digest = @computeDigest()

ApiExample.prototype.stripResponseBody = ->
  return unless @shouldStrip()

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
  "#{@http_method} #{@templatedURL}"

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

ApiExample.prototype.filteredUrl = (rawUrl)->
  return rawUrl if !rawUrl

  parasedRawUrl = url.parse(rawUrl, true)
  api_key_param = _u.find _u.keys(parasedRawUrl.query), (param) ->
    param.toLowerCase() == 'api_key'

  return rawUrl if !api_key_param

  rawUrl.replace("#{api_key_param}=#{parasedRawUrl.query[api_key_param]}", "#{api_key_param}=FILTERED")

ApiExample.prototype.computeDigest = ->
  text = "__VERSION__#{@version}__RESOURCE__#{@resource}__URL__#{@action}__DESC__#{@description}"
  hash = crypto.createHash('sha')
  console.log("digest for text #{text}")
  hash.update(text)
  hash.digest('base64')


ApiExample.prototype.shouldStrip = ->
  return true unless @requestHeaders
  console.log("HERE")
  strip_header_value = @requestHeaders[CUSTOM_HEADERS.NO_STRIP_HEADER]
  strip_header_value != 'true'

ApiExample.prototype.templatizeURL = ->
  path = @parsedUrl().pathname

  parts = path.split("/")

  templatedParts = _u.map parts, (part, index) ->
    previousPart = if index > 0 then parts[index-1] else ''

    return part unless validator.isAlpha(previousPart)

    if validator.isNumeric(part)
      "{:#{inflector.singularize(previousPart)}-id}"
    else if validator.isUUID(part)
      "{:#{inflector.singularize(previousPart)}-uuid}"
    else
      part

  @templatedURL = templatedParts.join('/')


module.exports = ApiExample



