Page    = require 'controllers/page'

User    = require 'zooniverse/models/user'
Recent  = require 'zooniverse/models/recent'


class Profile extends Page
  el: $('.profile')
  className: 'profile'
  template: require 'views/profile'
    
  constructor: ->
    super
    
    @html @template
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
  
  
  onUserChange: (e, user) =>
    if user?
      # Fetch recents after user is resolved
      Recent.fetch()
  
  onRecent: (e, recents) =>
    for recent in recents
      console.log recent
  
module.exports = Profile