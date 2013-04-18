
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
  
  onUserChange: (e, user) ->
    if user?
      Recent.fetch()
      Favorite.fetch()
    else
      console.log 'prompt user to sign in'
  
  onRecent: (e, recents) =>
    @recents.removeClass('loading')
    console.log recents
    params =
      subjects: recents
    @recents.html @subjectTemplate(params)
  
  onFavorite: (e, favorites) =>
    @favorites.removeClass('loading')
    params =
      subjects: favorites
    @favorites.html @subjectTemplate(params)


module.exports = Profile