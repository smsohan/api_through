_u = require('underscore')

class StrippedObject

  strip: (objectToStrip)->
    unless _u.isObject(objectToStrip)
      return objectToStrip

    if _u.isArray(objectToStrip)
      return _u.map objectToStrip[0..1], (itemToStrip) => @strip(itemToStrip)

    _u.reduce objectToStrip, (stripped, value, key) =>
        stripped[key] = @strip(value)
        stripped
      ,
        {}

module.exports = StrippedObject