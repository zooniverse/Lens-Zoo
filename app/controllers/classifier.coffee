
_     = require 'underscore/underscore'
Page  = require 'controllers/page'
Mark  = require 'controllers/Mark'


class Classifier extends Page
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  nSubjectCache: 5
  waitToRemove: 1000
  nSubjects: 0
  markings: {}
  maxMarkings: 5
  
  # TEMP CODE:
  ids: [1..30]
  
  elements:
    '[data-type="classified"]'    : 'nClassifiedEl'
    '[data-type="potentials"]'    : 'nPotentialsEl'
    '[data-type="favorites"]'     : 'nFavoritesEl'
    '.subjects'                   : 'subjects'
  
  events:
    'click div:nth(0)[data-type="heart"]'     : 'onFavorite'
    'click div:nth(0)[data-type="discuss"]'   : 'onDiscuss'
    'click div:nth(0)[data-type="dashboard"]' : 'onDashboard'
    'click div:nth(0)[data-type="finish"]'    : 'onFinish'
    'click .current .image svg'               : 'onMarking'
    'click circle'                            : 'onCircle'
  
  
  constructor: ->
    super
    
    @html @template
    
    # Get stats from API
    @nClassified = 123
    @nPotentials = 321
    @nFavorites = 987
    @setClassified()
    @setPotentials()
    @setFavorites()
    
    @initSubjects()
    @getCurrentSVG()
  
  removeMark: (m) =>
    index = m.index
    delete @markings[index]
    
    length = _.keys(@markings).length
    if length is 0
      @el.find('.current [data-type="finish"]').text('Nothing interesting')
      @hasMarking = false
  
  setClassified: =>
    @nClassifiedEl.text(@nClassified)
  
  setPotentials: =>
    @nPotentialsEl.text(@nPotentials)
  
  setFavorites: =>
    @nFavoritesEl.text(@nFavorites)
  
  getCurrentSVG: =>
    @svg = @el.find('.current').find('svg')
  
  # Select five random subjects.  This method is meant to be run once on init.
  initSubjects: =>
    # Check that there are enough subjects
    if @ids.length < 1
      alert 'Out of subjects'
      return null
    
    @getSubject() for i in [1..5]
    @warn = true
    @hasMarking = false
    @el.find('.subject').first().addClass('current')
  
  getSubject: =>
    
    # Get random number from array
    n = _.random(0, @ids.length - 1)
    id = String('0' + @ids[n]).slice(-2)
    @ids = _.without(@ids, @ids[n])
    url = "data/CFHTLS_#{id}.png"
    params =
      url: url
    @subjects.append @subjectTemplate(params)
  
  onMarking: (e) =>
    
    # Create marking and push to array
    index = _.keys(@markings).length
    mark = new Mark({el: @svg, x: e.offsetX, y: e.offsetY, index: index})
    mark.bind('remove', @removeMark)
    @markings[index] = mark
    
    # Replace text on interface
    unless @hasMarking
      @el.find('.current [data-type="finish"]').text('Finished marking!')
      @hasMarking = true
    
    # Warn user of over marking if exceeding maxMarkings
    return unless index + 1 > @maxMarkings
    random = Math.random()
    if random < 0.1 and @warn
      @warn = false
      alert("Whoa buddy!  Remember gravitional lenses are very rare astronomical objects.  There usually won't be this many interesting objects in an image.  If you think this is an exception, please discuss this image in Talk so that the science team can take a look!")
  
  # Prevent markings over SVG elements
  onCircle: (e) -> e.stopPropagation()
  
  onFavorite: (e) =>
    console.log 'onFavorite'
  
  onDiscuss: (e) =>
    console.log 'onDiscuss'
  
  onDashboard: (e) =>
    console.log 'onDashboard'
  
  onFinish: (e) =>
    
    # Get the marking info and push to API
    for index, mark of @markings
      console.log "#{mark.x}px #{mark.y}px"
    
    # Get DOM elements
    target = $(e.currentTarget)
    subject = target.parent().parent()
    sibling = subject.siblings().first()
    
    # Change classes
    subject.addClass('to-remove')
    subject.removeClass('current')
    
    sibling.addClass('current')
    sibling.removeClass('right')
    
    # Remove subject from DOM
    setTimeout ->
      subject.remove()
    , @waitToRemove
    
    # Request new subject and reset
    @getSubject() if @ids.length > 1
    @getCurrentSVG()
    @markings = {}
    @warn = true
    @hasMarking = false


module.exports = Classifier