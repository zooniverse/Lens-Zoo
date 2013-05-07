
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
    nClassified = 0
    nPotentials = 0
    nFavorites = 0
    
    if user?
      Recent.fetch()
      Favorite.fetch()
      
      project = user.project
      nClassified  = project.classification_count
      nPotentials  = project.annotation_count
      nFavorites   = project.favorite_count
      
      @el.find('.user').addClass('show')
      @el.find('.no-user').addClass('hide')
    else
      @el.find('.user').removeClass('show')
      @el.find('.no-user').removeClass('hide')
    
    @nClassifiedEl.text(nClassified)
    @nPotentialsEl.text(nPotentials)
    @nFavoritesEl.text(nFavorites)
  
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