(function() {
  var ApiExample, ApiExamplesSchema, CUSTOM_HEADERS, VERSION_IN_HEADER, VERSION_IN_URL, mongoose, url, _u;

  module.exports = function() {
    return new ApiExample();
  };

  mongoose = require('mongoose');

  url = require('url');

  _u = require('underscore');

  VERSION_IN_HEADER = /v(\d|\.\d)+/;

  VERSION_IN_URL = /\/(v\d[^\/]*)/;

  CUSTOM_HEADERS = {
    DESC_HEADER: "x-spy-rest-desc",
    VERSION_HEADER: "x-spy-rest-version",
    RESOURCE_HEADER: "x-spy-rest-resource"
  };

  ApiExamplesSchema = new mongoose.Schema({
    description: {
      type: String
    },
    version: {
      type: String
    },
    resource: {
      type: String
    },
    action: {
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
    http_method: {
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
  });

  ApiExamplesSchema.index({
    host: 1,
    version: 1,
    resource: 1,
    action: 1
  });

  ApiExample = mongoose.model('ApiExample', ApiExamplesSchema);

  ApiExample.prototype.populateFromRequest = function(request) {
    this.host = request.headers.host;
    this.url = request.url;
    this.http_method = request.method;
    this.requestHeaders = request.headers;
    this.description = request.headers[CUSTOM_HEADERS.DESC_HEADER];
    this.version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || this.guessedVersion();
    this.resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] || this.guessedResource();
    this.action = this.computedAction();
    return this.query = this.parsedUrl().query;
  };

  ApiExample.prototype.saveWithErrorLog = function() {
    return this.save(function(error) {
      if (error) {
        return console.log("Failed to save because of error", error);
      }
    });
  };

  ApiExample.prototype.guessedVersion = function() {
    console.log("@guessedVersionFromURL() = " + (this.guessedVersionFromURL()));
    console.log("@guessedVersionAcceptHeader() = " + (this.guessedVersionAcceptHeader()));
    return this.guessedVersionFromURL() || this.guessedVersionAcceptHeader();
  };

  ApiExample.prototype.guessedVersionFromURL = function() {
    if (this.url == null) {
      return null;
    }
    console.log("@url = " + this.url);
    if (this.url.match(VERSION_IN_URL)) {
      return RegExp.$1;
    }
  };

  ApiExample.prototype.guessedVersionAcceptHeader = function() {
    var matches;
    if (this.requestHeaders['accept'] == null) {
      return null;
    }
    matches = this.requestHeaders['accept'].match(VERSION_IN_HEADER);
    if (matches != null) {
      return matches[0];
    }
  };

  ApiExample.prototype.parsedUrl = function() {
    return url.parse(this.url, true);
  };

  ApiExample.prototype.guessedResource = function() {
    var parts, possibleResource;
    parts = this.parsedUrl().pathname.split('/').reverse();
    possibleResource = _u.find(parts, function(part) {
      return part.match(/^[^\d].*$/);
    });
    if (possibleResource != null) {
      return possibleResource.split('.')[0];
    }
  };

  ApiExample.prototype.computedAction = function() {
    return "" + this.http_method + " " + (this.parsedUrl().pathname);
  };

}).call(this);
