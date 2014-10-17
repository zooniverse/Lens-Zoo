Controller = require 'zooniverse/controllers/base-controller'
User = require 'zooniverse/models/user'
Recent = require 'zooniverse/models/recent'
Favorite = require 'zooniverse/models/favorite'

Counters = require 'controllers/counters'

class Profile extends Controller
  className: 'profile'
  template: require 'views/profile'
  subjectTemplate: require 'views/profile_subjects'
  
  favoritePage: 1
  recentPage: 1
  
  elements:
    '.favorites .subjects': 'favorites'
    '.recents .subjects': 'recents'
  
  events:
    'click .previous': 'getPrevious'
    'click .next': 'getNext'
  
  constructor: ->
    super
    
    # Initialize Counters
    @counters = new Counters({el: @el.find('.stats')})
    @counters.bind 'update', @counters.update
    
    User.on 'change', @onUserChange
    Recent.on 'fetch', @onRecent
    Favorite.on 'fetch', @onFavorite

    @el.on StackOfPages::activateEvent, @activate
  
  activate: =>
    @el.find('[data-type="sim-freq"]').parent().remove()
    if User.current
      Favorite.fetch per_page: 8
      Recent.fetch per_page: 8
      @prefetched = true
    super
  
  onUserChange: (e, user) =>
    if user?
      if @el.data('active-in-stack')
        Favorite.fetch per_page: 8
        Recent.fetch per_page: 8
        @prefetched = true
      
      @el.find('.user').addClass('show')
      @el.find('.no-user').addClass('hide')
    else
      @prefetched = false
      @el.find('.user').removeClass('show')
      @el.find('.no-user').removeClass('hide')
  
  onRecent: (e, recents) =>
    @recents.removeClass('loading')
    
    height = @recents.height()
    @recents.css('height', height)
    
    params =
      subjects: recents
    @recents.html @subjectTemplate(params)
    @recents.removeAttr("style")
  
  onFavorite: (e, favorites) =>
    @favorites.removeClass('loading')
    
    height = @favorites.height()
    @favorites.css('height', height)
    
    params =
      subjects: favorites
    @favorites.html @subjectTemplate(params)
    @favorites.removeAttr("style")
  
  getPrevious: (e) ->
    type = e.target.dataset.type
    model = type.charAt(0).toUpperCase() + type.slice(1)
    
    prevPage = Math.max 1, @["#{ type }Page"] - 1
    if prevPage isnt @["#{ type }Page"]
      @["#{ type }Page"] = prevPage
      zooniverse.models[model].fetch page: @["#{ type }Page"], per_page: 8
  
  getNext: (e) ->
    type = e.target.dataset.type
    model = type.charAt(0).toUpperCase() + type.slice(1)
    
    @["#{ type }Page"] += 1
    zooniverse.models[model].fetch page: @["#{ type }Page"], per_page: 8

module.exports = Profile
