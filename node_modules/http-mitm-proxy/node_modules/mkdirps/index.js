'use strict';

var mkdirp = require('mkdirp');
var async = require('async');

module.exports = function(dirs, callback) {
  if (typeof dirs === 'string') {
    dirs = [dirs];
  }
  if (!Array.isArray(dirs)) {
    return callback(new Error('Input not supported by mkdirps'));
  }

  async.forEach(dirs, mkdirp, function(err) {
    callback(err);
  });
};
