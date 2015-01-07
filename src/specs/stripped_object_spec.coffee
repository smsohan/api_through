describe 'StrippedObject', ->
  StrippedObject = require('../../lib/stripped_object')
  it 'strips the arrays to downto 2 elements only', ->
    originalObject = 
      a:
        b: [
            c: [ 1, 2, 3]
          ,
            d: [ 1, 2, 3]
          ,
            e: [ 1, 2, 3]
        ]

    strippedObject = new StrippedObject()
    expect(strippedObject.strip(originalObject)).toEqual a:
      b: [
          c: [1, 2]
        ,
          d: [1, 2]
      ]
