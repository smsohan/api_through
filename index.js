(function() {
  var ApiThough;

  ApiThough = require('./lib/api_through');

  process.on('uncaughtException', function(err) {
    console.error('uncaughtException');
    console.error(err);
    return console.error(err.stack);
  });

  new ApiThough().start();

}).call(this);
