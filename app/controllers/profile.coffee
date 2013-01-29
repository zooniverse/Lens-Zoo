Page    = require 'controllers/page'

User    = require 'zooniverse/models/user'
Recent  = require 'zooniverse/models/recent'


class Profile extends Page
  el: $('.profile')
  className: 'profile'
  template: require 'views/profile'
  
  constructor: ->
    super
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
  
  activate: =>
    super
    Recent.fetch() if User.current?
  
  onUserChange: (e, user) =>
    # Fetch recents after user is resolved
    Recent.fetch() if user?
  
  onRecent: (e, recents) =>
    params =
      recents: recents
      favorites: [] # TODO: Get favorites
    @html @template(params)
  
module.exports = Profile