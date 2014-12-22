var Proxy = require('http-mitm-proxy');
var ApiThough = require('./lib/api_through');

var proxy = new Proxy();
proxy.use(new ApiThough());
proxy.listen({port: 9081, sslCertCacheDir: './scripts/certs/http-mitm-proxy'});