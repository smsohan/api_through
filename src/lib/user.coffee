mongoose = require('mongoose')
_u = require('underscore')

UsersSchema = new mongoose.Schema
    api_token:
      type: String
  ,
    collection: 'users'

User = mongoose.model 'User', UsersSchema

module.exports = User