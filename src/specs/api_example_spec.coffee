mongooose = require('mongoose')
mongooose.connect('mongodb://localhost:27017/apis_test')

ApiExample = require('../../lib/api_example')

describe 'ApiExample', ->

  apiExample = null

  beforeEach ->
    apiExample = new ApiExample()

  describe '#guessedVersion', ->

    describe "guessed from URL", ->

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

    describe 'guessed from Accept header', ->
      beforeEach ->
        apiExample.url = "/users"

      it 'guesses v3 from application/vnd.github.v3+json', (done)->
        apiExample.requestHeaders =
          'accept': 'application/vnd.github.v3+json'

        apiExample.save ->
          expect(apiExample.version).toEqual("v3")
          done()

      it 'guesses v3.1 from application/vnd.github.v3.1+json', (done)->
        apiExample.requestHeaders =
          'accept': 'application/vnd.github.v3.1+json'

        apiExample.save ->
          expect(apiExample.version).toEqual("v3.1")
          done()

      it 'guesses v3.1 from application/vnd.github.v3.1-pre+json', (done)->
        apiExample.requestHeaders =
          'accept': 'application/vnd.github.v3.1+json'

        apiExample.save ->
          expect(apiExample.version).toEqual("v3.1")
          done()

    describe 'when version is found in both URL and header', ->
      it 'takes the one from URL', (done)->
        apiExample.url = "/v2/users"
        apiExample.requestHeaders =
          'accept': 'application/vnd.github.v3.1+json'

        apiExample.save ->
          expect(apiExample.version).toEqual("v2")
          done()

    describe 'when version is given through x-api-through-version header', ->
      it 'overlooks URL and Accept header', (done)->
        apiExample.populateFromRequest
          headers:
            "x-api-through-version": "v1"
            "accept": "application/vnd.github.v3.1+json"
          url: "/v2/users"

        apiExample.save ->
          expect(apiExample.version).toEqual("v1")
          done()
