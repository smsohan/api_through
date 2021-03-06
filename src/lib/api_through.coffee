module.exports = -> new ApiThrough()

PassThrough = require('stream').PassThrough

class ApiThrough
  Proxy = require('http-mitm-proxy')
  SSLCert = require('./ssl_cert')
  fs = require('fs')

  constructor: ->
    mongooose = require('mongoose')
    host = process.env["MONGODB_PORT_27017_TCP_ADDR"] || 'localhost'

    console.log("Connecting to mongo at #{host}")
    mongooose.connect("mongodb://#{host}:27017/apis")

  start: ->
    proxy = new Proxy()
    proxy.use(@)
    proxy.onCertificateMissing = (ctx, files, callback)=>
      @onCertificateMissing(ctx, files, callback)

    proxy.listen
      port: process.env['PROXY_PORT'] || 9081
      sslCertCacheDir: './scripts/certs/http-mitm-proxy'

    @proxy = proxy

  onCertificateMissing: (ctx, files, callback)->
    console.log('Looking for "%s" certificates',   ctx.hostname)
    console.log('"%s" missing', ctx.files.keyFile)
    console.log('"%s" missing', ctx.files.certFile)

    sslCert = new SSLCert(ctx.hostname)

    sslCert.create =>
      callback null,
        keyFileData: fs.readFileSync(ctx.files.keyFile)
        certFileData: fs.readFileSync(ctx.files.certFile)

  onError: (ctx, err)->
    console.error('proxy error:', err)
    console.error('proxy error stack:', err.stack)

  onRequest: (ctx, callback)->
    ApiExample = require('./api_example')
    User = require('./user')

    ctx.onError (ctx, err) => @onError(ctx, err)

    apiExample = new ApiExample()
    apiExample.populateFromRequest(ctx.clientToProxyRequest)
    apiExample.setFullUrl(ctx.isSSL, ctx.proxyToServerRequestOptions)

    responseBody = ''

    responseAggregator = new PassThrough()
    responseAggregator.on 'finish', ->
      apiExample.responseBody = responseBody
      apiExample.stripResponseBody()

      User.findOne {api_token: apiExample.apiToken}, (err, user)->
        console.log('findOne', err, user)
        apiExample.userId = user.id if user

        apiExampleRaw = apiExample.toObject()
        delete apiExampleRaw._id

        ApiExample.findOneAndUpdate
            digest: apiExample.digest
          ,
            apiExampleRaw
          ,
            upsert: true
          ,
            (error) ->
              console.log("Failed to save due to error", error) if error?

    ctx.addResponseFilter(responseAggregator)

    ctx.onRequestData (ctx, chunk, callback) ->
      apiExample.requestBody += chunk.toString('utf8')
      callback(null, chunk)

    ctx.onResponse (ctx, callback) ->
      apiExample.responseHeaders = ctx.serverToProxyResponse.headers
      apiExample.statusCode = ctx.serverToProxyResponse.statusCode

      ctx.serverToProxyResponse.on "finish", -> console.log("FINISH")
      callback()

    ctx.onResponseData (ctx, chunk, callback)->
      responseBody += chunk.toString('utf8')
      callback(null, chunk)

    callback()
