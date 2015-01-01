(function() {
  var ApiThrough, PassThrough;

  module.exports = function() {
    return new ApiThrough();
  };

  PassThrough = require('stream').PassThrough;

  ApiThrough = (function() {
    var Proxy;

    Proxy = require('http-mitm-proxy');

    function ApiThrough() {
      var host, mongooose;
      mongooose = require('mongoose');
      host = process.env["MONGODB_PORT_27017_TCP_ADDR"] || 'localhost';
      console.log("Connecting to mongo at " + host);
      mongooose.connect("mongodb://" + host + ":27017/apis");
    }

    ApiThrough.prototype.start = function() {
      var proxy;
      proxy = new Proxy();
      proxy.use(this);
      proxy.listen({
        port: process.env['PROXY_PORT'] || 9081,
        sslCertCacheDir: './scripts/certs/http-mitm-proxy'
      });
      return this.proxy = proxy;
    };

    ApiThrough.prototype.onError = function(ctx, err) {
      console.error('proxy error:', err);
      return console.error('proxy error stack:', err.stack);
    };

    ApiThrough.prototype.onRequest = function(ctx, callback) {
      var ApiExample, apiExample, responseAggregator, responseBody;
      ApiExample = require('./api_example');
      ctx.onError((function(_this) {
        return function(ctx, err) {
          return _this.onError(ctx, err);
        };
      })(this));
      apiExample = new ApiExample();
      apiExample.populateFromRequest(ctx.clientToProxyRequest);
      console.log(ctx.proxyToServerRequestOptions);
      apiExample.setFullUrl(ctx.isSSL, ctx.proxyToServerRequestOptions);
      responseBody = '';
      responseAggregator = new PassThrough();
      responseAggregator.on('finish', function() {
        apiExample.responseBody = responseBody;
        return apiExample.saveWithErrorLog();
      });
      ctx.addResponseFilter(responseAggregator);
      ctx.onRequestData(function(ctx, chunk, callback) {
        apiExample.requestBody += chunk.toString('utf8');
        return callback(null, chunk);
      });
      ctx.onResponse(function(ctx, callback) {
        apiExample.responseHeaders = ctx.serverToProxyResponse.headers;
        apiExample.statusCode = ctx.serverToProxyResponse.statusCode;
        ctx.serverToProxyResponse.on("finish", function() {
          return console.log("FINISH");
        });
        apiExample.saveWithErrorLog();
        return callback();
      });
      ctx.onResponseData(function(ctx, chunk, callback) {
        responseBody += chunk.toString('utf8');
        return callback(null, chunk);
      });
      return callback();
    };

    return ApiThrough;

  })();

}).call(this);
