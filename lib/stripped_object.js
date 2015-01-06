(function() {
  var StrippedObject, _u;

  _u = require('underscore');

  StrippedObject = (function() {
    function StrippedObject() {}

    StrippedObject.prototype.strip = function(objectToStrip) {
      if (!_u.isObject(objectToStrip)) {
        return objectToStrip;
      }
      if (_u.isArray(objectToStrip)) {
        return _u.map(objectToStrip.slice(0, 2), (function(_this) {
          return function(itemToStrip) {
            return _this.strip(itemToStrip);
          };
        })(this));
      }
      return _u.reduce(objectToStrip, (function(_this) {
        return function(stripped, value, key) {
          stripped[key] = _this.strip(value);
          return stripped;
        };
      })(this), {});
    };

    return StrippedObject;

  })();

  module.exports = StrippedObject;

}).call(this);
