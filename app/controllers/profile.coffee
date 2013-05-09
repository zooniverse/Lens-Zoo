
Page      = require 'controllers/page'
Counters  = require 'controllers/counters'

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
    
    # Initialize Counters
    @counters = new Counters({el: @el.find('.stats')})
    @counters.removeSimulationFrequency()
    @counters.bind 'update', @counters.update
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
    Favorite.on 'fetch', @onFavorite
  
  onUserChange: (e, user) =>
    
    if user?
      Recent.fetch()
      Favorite.fetch()
      
      @el.find('.user').addClass('show')
      @el.find('.no-user').addClass('hide')
    else
      @el.find('.user').removeClass('show')
      @el.find('.no-user').removeClass('hide')
  
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