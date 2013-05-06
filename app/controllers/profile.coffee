
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
    '.favorites .subjects'      : 'favorites'
    '.recents .subjects'        : 'recents'
    '[data-type="classified"]'  : 'nClassifiedEl'
    '[data-type="potentials"]'  : 'nPotentialsEl'
    '[data-type="favorites"]'   : 'nFavoritesEl'
  
  
  constructor: ->
    super
    @html @template
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
    Favorite.on 'fetch', @onFavorite
  
  onUserChange: (e, user) =>
    if user?
      Recent.fetch()
      Favorite.fetch()
      
      project = user.project
      console.log project
      nClassified  = project.classification_count
      nPotentials  = project.annotation_count
      nFavorites   = project.favorite_count
      
      @nClassifiedEl.text(nClassified)
      @nPotentialsEl.text(nPotentials)
      @nFavoritesEl.text(nFavorites)
    else
      alert "Please sign in to see your profile."
  
  onRecent: (e, recents) =>
    @recents.removeClass('loading')
    params =
      subjects: recents
    @recents.html @subjectTemplate(params)
  
  onFavorite: (e, favorites) =>
    @favorites.removeClass('loading')
    params =
      subjects: favorites
    @favorites.html @subjectTemplate(params)


module.exports = Profile