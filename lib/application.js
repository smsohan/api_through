(function() {
  var ApiThoughContext, ApiThrough;

  module.exports = function() {
    return new ApiThrough();
  };

  ApiThrough = (function() {
    function ApiThrough() {}

    ApiThrough.prototype.onError = function(ctx, err) {
      return console.error('proxy error:', err);
    };

    ApiThrough.prototype.onRequest = function(ctx, callback) {
      console.log('URL:', ctx.clientToProxyRequest.url);
      console.log('REQUEST HEADERS:', ctx.clientToProxyRequest.headers);
      console.log("REQUEST DONE");
      ctx.use(new ApiThoughContext());
      return callback();
    };

    return ApiThrough;

  })();

  ApiThoughContext = (function() {
    var onResponseData;

    function ApiThoughContext() {}

    ApiThoughContext.prototype.onResponse = function(ctx, callback) {
      console.log("RESPONSE HEADERS:", ctx.serverToProxyResponse.headers);
      return callback();
    };

    onResponseData = function(ctx, chunk, callback) {
      console.log("RESPONSE DATA:", chunk.toString('utf8'));
      return callback(null, chunk);
    };

    return ApiThoughContext;

  })();

}).call(this);
