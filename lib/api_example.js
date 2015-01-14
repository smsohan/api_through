(function() {
  var ApiExample, ApiExamplesSchema, CUSTOM_HEADERS, VERSION_IN_HEADER, VERSION_IN_URL, crypto, mongoose, url, _u;

  mongoose = require('mongoose');

  url = require('url');

  _u = require('underscore');

  crypto = require('crypto');

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
      type: String,
      "default": 'Default'
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
    },
    strippedResponseBody: {
      type: String,
      "default": ''
    },
    recordedAt: {
      type: Date,
      "default": function() {
        return new Date();
      }
    },
    fullURL: {
      type: String,
      "default": ''
    },
    digest: {
      type: String,
      "default": ''
    },
    requiresAuth: {
      type: Boolean,
      "default": false
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
    this.version = request.headers[CUSTOM_HEADERS.VERSION_HEADER] || this.guessedVersion() || 'Default';
    this.resource = request.headers[CUSTOM_HEADERS.RESOURCE_HEADER] || this.guessedResource();
    this.action = this.computedAction();
    this.query = this.parsedUrl().query;
    this.digest = this.computeDigest();
    return this.filterAuthHeaders();
  };

  ApiExample.prototype.stripResponseBody = function() {
    var StrippedObject, strippedObject;
    StrippedObject = require('./stripped_object');
    strippedObject = new StrippedObject();
    try {
      return this.strippedResponseBody = JSON.stringify(strippedObject.strip(JSON.parse(this.responseBody)));
    } catch (_error) {
      return this.strippedResponseBody = this.responseBody;
    }
  };

  ApiExample.prototype.saveWithErrorLog = function() {
    return this.save(function(error) {
      if (error) {
        return console.error("Failed to save because of error", error);
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

  ApiExample.prototype.setFullUrl = function(isSSL, hostPort) {
    var host, port, scheme;
    scheme = isSSL ? "https" : "http";
    host = hostPort.host;
    if (scheme === "http" && hostPort.port !== 80) {
      port = ":" + hostPort.port;
    } else if (scheme === "https" && hostPort.port !== 443) {
      port = ":" + hostPort.port;
    } else {
      port = '';
    }
    return this.fullURL = "" + scheme + "://" + host + port + this.url;
  };

  ApiExample.prototype.filterAuthHeaders = function() {
    return this.requestHeaders = _u.reduce(this.requestHeaders, (function(_this) {
      return function(filteredHeaders, value, key) {
        if (key === 'authorization') {
          filteredHeaders[key] = 'FILTERED';
          _this.requiresAuth = true;
        } else {
          filteredHeaders[key] = value;
        }
        return filteredHeaders;
      };
    })(this), {});
  };

  ApiExample.prototype.computeDigest = function() {
    var hash, text;
    text = "__VERSION__" + this.version + "__RESOURCE__" + this.resource + "__URL__" + this.url + "__DESC__" + this.description;
    hash = crypto.createHash('sha');
    console.log("digest for text " + text);
    hash.update(text);
    return hash.digest('base64');
  };

  module.exports = ApiExample;

}).call(this);
