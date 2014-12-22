(function() {
  var ApiExample, mongoose;

  module.exports = function() {
    return new ApiExample();
  };

  mongoose = require('mongoose');

  ApiExample = mongoose.model('ApiExample', new mongoose.Schema({
    url: {
      type: String
    },
    host: {
      type: String
    },
    method: {
      type: String
    },
    requestHeaders: {
      type: Object
    },
    responseHeaders: {
      type: Object
    },
    responseBody: {
      type: String,
      "default": ''
    }
  }));

  ApiExample.prototype.saveWithErrorLog = function() {
    return this.save(function(error) {
      if (error) {
        return console.log("Failed to save because of error", error);
      }
    });
  };

}).call(this);
