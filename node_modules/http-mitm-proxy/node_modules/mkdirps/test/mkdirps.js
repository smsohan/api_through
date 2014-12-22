var mkdirps = require('../');
var fs = require('fs');
var async = require('async');
var test = require('tap').test;

test('multiple mkdirps', function(t) {
  var numTests = 10;
  var files = [];
  t.plan(numTests);

  for (var i = 0; i < numTests; i++) {
    var x = Math.floor(Math.random() * Math.pow(16,4)).toString(16);
    var y = Math.floor(Math.random() * Math.pow(16,4)).toString(16);
    var z = Math.floor(Math.random() * Math.pow(16,4)).toString(16);
    files.push('/tmp/' + [x,y,z].join('/'));
  }

  mkdirps(files, function (err) {
    if (err) {
      t.fail(err);
    }

    async.forEach(files, testDir, function(err) {
      t.end();
    });

    function testDir(file) {
      fs.exists(file, function (exists) {
        if (!exists) {
          t.fail('fail not created');
        }
        fs.stat(file, function (err, stats) {
          if (err) {
            t.fail(err);
          }
          t.ok(stats.isDirectory(), 'target not a directory');
        });
      });
    }
  });
});

test('single mkdirp', function(t) {
  t.plan(1);
  var x = Math.floor(Math.random() * Math.pow(16,4)).toString(16);
  var y = Math.floor(Math.random() * Math.pow(16,4)).toString(16);
  var z = Math.floor(Math.random() * Math.pow(16,4)).toString(16);

  var file = '/tmp/' + [x,y,z].join('/');

  mkdirps(file, function (err) {
    if (err) {
      t.fail(err);
    }
    fs.exists(file, function (exists) {
      if (!exists) {
        t.fail('fail not created');
      }
      fs.stat(file, function (err, stats) {
        if (err) {
          t.fail(err);
        }
        t.ok(stats.isDirectory(), 'target not a directory');
        t.end();
      });
    });
  });
});

test('fail on invalid args', function(t) {
  t.plan(1);

  mkdirps({}, function (err) {
    t.ok(err);
    t.end();
  });
});