_u = require('underscore')

class StrippedObject

  strip: (objectToStrip)->
    unless _u.isObject(objectToStrip)
      return objectToStrip

    if _u.isArray(objectToStrip)
      return objectToStrip[0..1]

    stripped = {}

    _u.each objectToStrip, (value, key) =>
      if _u.isObject(value)
        stripped[key] = @strip(value)
      else
        stripped[key] = value

    stripped

module.exports = StrippedObject