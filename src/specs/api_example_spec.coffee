mongooose = require('mongoose')
mongooose.connect('mongodb://localhost:27017/apis_test')

ApiExample = require('../../lib/api_example')

describe 'ApiExample', ->

  apiExample = null

  beforeEach ->
    apiExample = new ApiExample()

  describe '#guessedVersion', ->
    it 'guesses /v2/x to version v2', (done)->
      apiExample.url = '/v2/x'
      apiExample.save ->
        expect(apiExample.version).toEqual("v2")
        done()

    it 'guesses /v2.1/x to version v2.1', (done)->
      apiExample.url = '/v2.1/x'
      apiExample.save ->
        expect(apiExample.version).toEqual("v2.1")
        done()

    it 'guesses /v2 to version v2', (done)->
      apiExample.url = '/v2'
      apiExample.save ->
        expect(apiExample.version).toEqual("v2")
        done()

    it 'guesses /v2.1-pre/users to version v2.1-pre', (done)->
      apiExample.url = '/v2.1-pre'
      apiExample.save ->
        expect(apiExample.version).toEqual("v2.1-pre")
        done()





