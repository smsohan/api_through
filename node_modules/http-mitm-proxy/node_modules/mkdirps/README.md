node-mkdirps
============

Make multiple directories (each recursively using mkdir -p) all in parallel

Quick Example
=============

    var mkdirps = require('mkdirps');
    var dirs = ['/tmp/foo', '/tmp/baz', '/tmp/bar'];

    mkdirps(dirs, function (err) {
      if (err) {
        return console.error(err);
      }
      console.log('dirs created!');
    });

Installation
============

    npm install mkdirps

License
=======

MIT

Shout Outs
=======

Special thanks to @substack for [mkdirp](https://github.com/substack/node-mkdirp/) of which this module wraps and to Sean Pilkenton for his module naming skills.
