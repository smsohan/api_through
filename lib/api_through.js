(function() {
  var ApiThrough;

  module.exports = function() {
    return new ApiThrough();
  };

  ApiThrough = (function() {
    var Proxy;

    Proxy = require('http-mitm-proxy');

    function ApiThrough() {
      this.mongooose = require('mongoose');
      this.mongooose.connect('mongodb://localhost:27017/apis');
    }

    ApiThrough.prototype.start = function() {
      var proxy;
      proxy = new Proxy();
      proxy.use(this);
      return proxy.listen({
        port: 9081,
        sslCertCacheDir: './scripts/certs/http-mitm-proxy'
      });
    };

    ApiThrough.prototype.onError = function(ctx, err) {
      return console.error('proxy error:', err);
    };

    ApiThrough.prototype.onRequest = function(ctx, callback) {
      var ApiExample, apiExample;
      ApiExample = require('./api_example');
      apiExample = new ApiExample();
      apiExample.host = ctx.clientToProxyRequest.headers.host;
      apiExample.url = ctx.clientToProxyRequest.url;
      apiExample.method = ctx.clientToProxyRequest.method;
      apiExample.requestHeaders = ctx.clientToProxyRequest.headers;
      ctx.onRequestData(function(ctx, chunk, callback) {
        apiExample.requestBody += chunk.toString('utf8');
        return callback(null, chunk);
      });
      ctx.onResponse(function(ctx, callback) {
        apiExample.responseHeaders = ctx.serverToProxyResponse.headers;
        apiExample.statusCode = ctx.serverToProxyResponse.statusCode;
        apiExample.saveWithErrorLog();
        return callback();
      });
      ctx.onResponseData(function(ctx, chunk, callback) {
        apiExample.responseBody += chunk.toString('utf8');
        apiExample.saveWithErrorLog();
        return callback(null, chunk);
      });
      return callback();
    };

    return ApiThrough;

  })();

}).call(this);
