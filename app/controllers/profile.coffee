
Page      = require 'controllers/page'

User      = require 'zooniverse/models/user'
Recent    = require 'zooniverse/models/recent'
Favorite  = require 'zooniverse/models/favorite'


class Profile extends Page
  el: $('.profile')
  className: 'profile'
  template: require 'views/profile'
  subjectTemplate: require 'views/profile_subjects'
  
  elements:
    '.favorites .subjects'  : 'favorites'
    '.recents .subjects'    : 'recents'
  
  
  constructor: ->
    super
    @html @template
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
    Favorite.on 'fetch', @onFavorite
  
  activate: =>
    super
  
  onUserChange: (e, user) =>
    # After user is resolved fetch recents and favorites
    if user?
      Recent.fetch()
      Favorite.fetch()
  
  onRecent: (e, recents) =>
    console.log 'onRecent'
    
    @recents.removeClass('loading')
    params =
      subjects: recents
    @recents.html @subjectTemplate(params)
  
  onFavorite: (e, favorites) =>
    console.log 'onFavorite', favorites
    @favorites.removeClass('loading')
    params =
      subjects: favorites
    @favorites.html @subjectTemplate(params)

module.exports = Profile