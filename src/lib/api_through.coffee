module.exports = -> new ApiThrough()

class ApiThrough
  Proxy = require('http-mitm-proxy')

  constructor: ->
    mongooose = require('mongoose')
    mongooose.connect('mongodb://localhost:27017/apis')

  start: ->
    proxy = new Proxy()

    proxy.use(@)
    proxy.listen
      port: 9081
      sslCertCacheDir: './scripts/certs/http-mitm-proxy'

  onError: (ctx, err)->
    console.error('proxy error:', err)

  onRequest: (ctx, callback)->
    ApiExample = require('./api_example')

    apiExample = new ApiExample()
    apiExample.description = ctx.clientToProxyRequest.headers['x-api-through-desc']
    apiExample.version = ctx.clientToProxyRequest.headers['x-api-through-version']
    apiExample.resource = ctx.clientToProxyRequest.headers['x-api-through-resource']
    apiExample.host = ctx.clientToProxyRequest.headers.host
    apiExample.url = ctx.clientToProxyRequest.url
    apiExample.method = ctx.clientToProxyRequest.method
    apiExample.requestHeaders = ctx.clientToProxyRequest.headers

    ctx.onRequestData (ctx, chunk, callback) ->
      apiExample.requestBody += chunk.toString('utf8')
      callback(null, chunk)

    ctx.onResponse (ctx, callback) ->
      apiExample.responseHeaders = ctx.serverToProxyResponse.headers
      apiExample.statusCode = ctx.serverToProxyResponse.statusCode

      apiExample.saveWithErrorLog()
      callback()

    ctx.onResponseData (ctx, chunk, callback)->
      apiExample.responseBody += chunk.toString('utf8')
      apiExample.saveWithErrorLog()
      callback(null, chunk)

    callback()
