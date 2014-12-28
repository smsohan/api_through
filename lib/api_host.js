(function() {
  var ApiHost, mongoose;

  mongoose = require('mongoose');

  ApiHost = mongoose.model('ApiHost', new mongoose.Schema({
    name: {
      type: String
    },
    versions: {
      type: Array
    }
  }, {
    collection: 'api_hosts'
  }));

  module.exports = ApiHost;

}).call(this);
