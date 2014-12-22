module.exports = function() {
  return new ApiThrough();
};

var ApiThrough = function(){

};

ApiThrough.prototype.onError = function(ctx, err) {
  console.error('proxy error:', err);
};

ApiThrough.prototype.onRequest = function(ctx, callback) {
  console.log('URL:', ctx.clientToProxyRequest.url);
  console.log('REQUEST HEADERS:', ctx.clientToProxyRequest.headers);

  ctx.use(new ApiThoughContext());
  return callback();
};


ApiThoughContext = function(){

};

ApiThoughContext.prototype.onResponse = function(ctx, callback) {
  console.log("RESPONSE HEADERS:", ctx.serverToProxyResponse.headers)
  return callback();
};

ApiThoughContext.prototype.onResponseData = function(ctx, chunk, callback) {
  console.log("RESPONSE DATA:", chunk.toString('utf8'));
  return callback(null, chunk);
};