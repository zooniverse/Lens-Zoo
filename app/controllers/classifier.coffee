
_     = require 'underscore/underscore'
Page  = require 'controllers/page'
Mark  = require 'controllers/Mark'

User    = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'

Classification = require 'models/classification'


class Classifier extends Page
  el: $('.classifier')
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  
  subjects: []
  maxMarkings: 5
  
  elements:
    '[data-type="classified"]'    : 'nClassifiedEl'
    '[data-type="potentials"]'    : 'nPotentialsEl'
    '[data-type="favorites"]'     : 'nFavoritesEl'
    '.subjects'                   : 'subjectsEl'
  
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
    
    # Setup events
    # User.on 'change', @onUserChange
    Subject.on 'fetch', @onInitialFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
  
  activate: =>
    super
    
    # Request subjects only when user hits classify page the first time
    Subject.fetch({limit: 5}) unless @hasVisited
    @hasVisited = true
  
  # onUserChange: (e, user) =>
  #   if user?.project.tutorial_done
  #     if @classification.subject.metadata.tutorial
  #       Subject.next()
  #   else
  #     Subject.next()
  
  reset: =>
    @markings     = {}
    @markingIndex = 0
    @warn         = true
    @hasMarking   = false
    @createClassification()
    @setCurrentSVG()
  
  onInitialFetch: (e, data) =>
    for subject in data
      @subjects.push(subject)
      params = 
        url: subject.location.standard
      @subjectsEl.append @subjectTemplate(params)
    
    @reset()
    
    @el.find('.subject').first().addClass('current')
    @setCurrentSVG()
  
  onSubjectSelect: (e, subject) =>
    @subjects.push(subject)
  
  onNoMoreSubjects: =>
    console.log 'onNoMoreSubjects'
  
  createClassification: =>
    subject = @subjects.shift()
    @classification = new Classification {subject}
  
  setClassified: =>
    @nClassifiedEl.text(@nClassified)
  
  setPotentials: =>
    @nPotentialsEl.text(@nPotentials)
  
  setFavorites: =>
    @nFavoritesEl.text(@nFavorites)
  
  setCurrentSVG: =>
    @svg = @el.find('.current').find('svg')
  
  onMarking: (e) =>
    
    # Create marking and push to object
    mark = new Mark({el: @svg, x: e.offsetX, y: e.offsetY, index: @markingIndex})
    @markings[@markingIndex] = mark
    @markingIndex += 1
    mark.bind('remove', @removeMark)
    
    # Replace text on interface
    unless @hasMarking
      @el.find('.current [data-type="finish"]').text('Finished marking!')
      @hasMarking = true
    
    count = _.keys(@markings).length
    return unless count + 1 > @maxMarkings
    random = Math.random()
    if random < 0.1 and @warn
      @warn = false
      # TODO: Make this look nice.  Warn user of over marking if exceeding maxMarkings
      alert("Whoa buddy!  Remember gravitional lenses are very rare astronomical objects.  There usually won't be this many interesting objects in an image.  If you think this is an exception, please discuss this image in Talk so that the science team can take a look!")
  
  removeMark: (m) =>
    index = m.index
    delete @markings[index]

    count = _.keys(@markings).length
    if count is 0
      @el.find('.current [data-type="finish"]').text('Nothing interesting')
      @hasMarking = false
  
  # Prevent markings over SVG elements
  onCircle: (e) -> e.stopPropagation()
  
  onFavorite: (e) =>
    console.log 'onFavorite'
  
  onDiscuss: (e) =>
    console.log 'onDiscuss'
  
  onDashboard: (e) =>
    console.log 'onDashboard'
  
  onFinish: (e) =>
    
    # Process markings and push to API
    for index, mark of @markings
      @classification.annotate(mark.toJSON())
    @classification.send()
    
    # Get DOM elements
    target  = $(e.currentTarget)
    current = $('.current')
    next    = current.siblings().first()
    
    # Change classes
    current.addClass('to-remove')
    current.removeClass('current')
    
    next.addClass('current')
    next.removeClass('right')
    
    # Remove subject from DOM
    setTimeout ->
      current.remove()
    , 1000
    
    Subject.next()
    @reset()


module.exports = Classifier