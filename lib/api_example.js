(function() {
  var ApiExample, VERSION_IN_HEADER, VERSION_IN_URL, mongoose;

  module.exports = function() {
    return new ApiExample();
  };

  mongoose = require('mongoose');

  VERSION_IN_HEADER = /v[\d.]+/;

  VERSION_IN_URL = /\/(v\d[^\/]*)/;

  ApiExample = mongoose.model('ApiExample', new mongoose.Schema({
    description: {
      type: String
    },
    version: {
      type: String
    },
    url: {
      type: String
    },
    host: {
      type: String
    },
    method: {
      type: String
    },
    requestBody: {
      type: String,
      "default": ''
    },
    requestHeaders: {
      type: Object
    },
    statusCode: {
      type: Number
    },
    responseHeaders: {
      type: Object
    },
    responseBody: {
      type: String,
      "default": ''
    }
  }, {
    collection: 'api_examples'
  }));

  ApiExample.schema.pre('save', function(callback) {
    if (!this.version) {
      this.version = this.guessedVersion();
    }
    return callback();
  });

  ApiExample.prototype.saveWithErrorLog = function() {
    return this.save(function(error) {
      if (error) {
        return console.log("Failed to save because of error", error);
      }
    });
  };

  ApiExample.prototype.guessedVersion = function() {
    return this.guessedVersionFromURL() || this.guessedVersionAcceptHeader();
  };

  ApiExample.prototype.guessedVersionFromURL = function() {
    if (this.url == null) {
      return null;
    }
    this.url.match(VERSION_IN_URL);
    return RegExp.$1;
  };

  ApiExample.prototype.guessedVersionAcceptHeader = function() {
    if (this.requestHeaders['accept'] == null) {
      return null;
    }
    return this.requestHeaders['accept'].match(VERSION_IN_HEADER);
  };

}).call(this);
