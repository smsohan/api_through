module.exports = -> new ApiThrough()

class ApiThrough

  onError: (ctx, err)->
    console.error('proxy error:', err)

  onRequest: (ctx, callback)->
    console.log('URL:', ctx.clientToProxyRequest.url)
    console.log('REQUEST HEADERS:', ctx.clientToProxyRequest.headers)
    console.log("REQUEST DONE")
    ctx.use(new ApiThoughContext())
    callback()


class ApiThoughContext
  onResponse: (ctx, callback) ->
    console.log("RESPONSE HEADERS:", ctx.serverToProxyResponse.headers)
    callback()

  onResponseData = (ctx, chunk, callback)->
    console.log("RESPONSE DATA:", chunk.toString('utf8'))
    callback(null, chunk)