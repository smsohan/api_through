var mkdirps = require('../');
var dirs = ['/tmp/foo', '/tmp/baz', '/tmp/bar'];

mkdirps(dirs, function (err) {
  if (err) {
    return console.error(err);
  }
  console.log('dirs created!');
});