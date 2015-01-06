_u = require('underscore')

class StrippedObject

  strip: (objectToStrip)->
    unless _u.isObject(objectToStrip)
      return objectToStrip

    if _u.isArray(objectToStrip)
      return _u.map objectToStrip[0..1], (itemToStrip) => @strip(itemToStrip)

    stripped = {}

    _u.each objectToStrip, (value, key) =>
      if _u.isObject(value)
        stripped[key] = @strip(value)
      else
        stripped[key] = value

    stripped

module.exports = StrippedObject