(function() {
  var ApiThough, Proxy, proxy;

  Proxy = require('http-mitm-proxy');

  ApiThough = require('./lib/application');

  proxy = new Proxy();

  proxy.use(new ApiThough());

  proxy.listen({
    port: 9081,
    sslCertCacheDir: './scripts/certs/http-mitm-proxy'
  });

}).call(this);
