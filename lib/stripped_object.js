(function() {
  var StrippedObject, _u;

  _u = require('underscore');

  StrippedObject = (function() {
    function StrippedObject() {}

    StrippedObject.prototype.strip = function(objectToStrip) {
      var stripped;
      if (!_u.isObject(objectToStrip)) {
        return objectToStrip;
      }
      if (_u.isArray(objectToStrip)) {
        return objectToStrip.slice(0, 2);
      }
      stripped = {};
      _u.each(objectToStrip, (function(_this) {
        return function(value, key) {
          if (_u.isObject(value)) {
            return stripped[key] = _this.strip(value);
          } else {
            return stripped[key] = value;
          }
        };
      })(this));
      return stripped;
    };

    return StrippedObject;

  })();

  module.exports = StrippedObject;

}).call(this);
