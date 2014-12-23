mongoose = require('mongoose')
mongoose.connect('mongodb://localhost:27017/apis_test')

ApiExample = require('../../lib/api_example')

describe 'ApiExample', ->

  apiExample = null

  beforeEach ->
    apiExample = new ApiExample()
    apiExample.requestHeaders = {}

  afterEach (done)->
    mongoose.connection.collections['api_examples'].drop -> done()

  describe '#populateFromRequest', ->
    it 'assigns the host from the request headers', ->
      request =
        url: '/users'
        method: 'PUT'
        headers:
          host: 'api_though.io'
          "x-api-through-desc": 'shows a list of users'
          "x-api-through-version": 'v1'
          "x-api-through-resource": 'user'

      apiExample.populateFromRequest(request)

      expect(apiExample.host).toEqual('api_though.io')
      expect(apiExample.url).toEqual('/users')
      expect(apiExample.method).toEqual('PUT')

      expect(apiExample.description).toEqual('shows a list of users')
      expect(apiExample.version).toEqual('v1')
      expect(apiExample.resource).toEqual('user')

      expect(apiExample.requestHeaders).toEqual(request.headers)

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

  describe '#guessedResource', ->
    it 'guesses /users to users', (done)->
      apiExample.url = '/users'

      apiExample.save ->
        expect(apiExample.resource).toEqual("users")
        done()

    it 'guesses /users/10 to users', (done)->
      apiExample.url = '/users/10'

      apiExample.save ->
        expect(apiExample.resource).toEqual("users")
        done()

    it 'guesses /users/10/repos to repos', (done)->
      apiExample.url = '/users/10/repos'

      apiExample.save ->
        expect(apiExample.resource).toEqual("repos")
        done()

    it 'guesses /users/10/100/1000 to users', (done)->
      apiExample.url = '/users/10/100/1000'

      apiExample.save ->
        expect(apiExample.resource).toEqual("users")
        done()

    it 'overlooks the url in case the x-api-through-resource header is present', (done)->
      apiExample.populateFromRequest
        url: '/users/10/100/1000'
        headers:
          "x-api-through-resource": 'person'

      apiExample.save ->
        expect(apiExample.resource).toEqual("person")
        done()










