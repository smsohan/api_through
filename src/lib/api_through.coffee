module.exports = -> new ApiThrough()

PassThrough = require('stream').PassThrough

class ApiThrough
  Proxy = require('http-mitm-proxy')

  constructor: ->
    mongooose = require('mongoose')
    host = process.env["MONGODB_PORT_27017_TCP_ADDR"] || 'localhost'

    console.log("Connecting to mongo at #{host}")
    mongooose.connect("mongodb://#{host}:27017/apis")

  start: ->
    proxy = new Proxy()
    proxy.use(@)
    proxy.listen
      port: process.env['PROXY_PORT'] || 9081
      sslCertCacheDir: './scripts/certs/http-mitm-proxy'

    @proxy = proxy

  onError: (ctx, err)->
    console.error('proxy error:', err)

  onRequest: (ctx, callback)->
    ApiExample = require('./api_example')

    apiExample = new ApiExample()
    apiExample.populateFromRequest(ctx.clientToProxyRequest)

    responseBody = ''

    responseAggregator = new PassThrough()
    responseAggregator.on 'finish', ->
      apiExample.responseBody = responseBody
      apiExample.saveWithErrorLog()

    ctx.addResponseFilter(responseAggregator)

    ctx.onRequestData (ctx, chunk, callback) ->
      apiExample.requestBody += chunk.toString('utf8')
      callback(null, chunk)

    ctx.onResponse (ctx, callback) ->
      apiExample.responseHeaders = ctx.serverToProxyResponse.headers
      apiExample.statusCode = ctx.serverToProxyResponse.statusCode

      ctx.serverToProxyResponse.on "finish", -> console.log("FINISH")

      apiExample.saveWithErrorLog()
      callback()

    ctx.onResponseData (ctx, chunk, callback)->
      responseBody += chunk.toString('utf8')
      callback(null, chunk)

    callback()
