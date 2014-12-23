(function() {
  var ApiExample, VERSION_IN_HEADER, VERSION_IN_URL, mongoose, url, _u;

  module.exports = function() {
    return new ApiExample();
  };

  mongoose = require('mongoose');

  url = require('url');

  _u = require('underscore');

  VERSION_IN_HEADER = /v[\d.]+/;

  VERSION_IN_URL = /\/(v\d[^\/]*)/;

  ApiExample = mongoose.model('ApiExample', new mongoose.Schema({
    description: {
      type: String
    },
    version: {
      type: String
    },
    resource: {
      type: String
    },
    url: {
      type: String
    },
    query: {
      type: Object
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
    if (!this.query) {
      this.query = this.parsedUrl().query;
    }
    if (!this.version) {
      this.version = this.guessedVersion();
    }
    if (!this.resource) {
      this.resource = this.guessedResource();
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

  ApiExample.prototype.parsedUrl = function() {
    return url.parse(this.url, true);
  };

  ApiExample.prototype.guessedResource = function() {
    var parts;
    parts = this.parsedUrl().pathname.split('/').reverse();
    return _u.find(parts, function(part) {
      return part.match(/^[^\d].*$/);
    });
  };

}).call(this);
