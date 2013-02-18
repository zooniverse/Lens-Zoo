
_     = require 'underscore/underscore'

User            = require 'zooniverse/models/user'
Subject         = require 'zooniverse/models/subject'
Favorite        = require 'zooniverse/models/favorite'
Classification  = require 'models/classification'

Page          = require 'controllers/page'
Annotation    = require 'controllers/Annotation'
{Tutorial}    = require 'zootorial'
TutorialSteps = require 'lib/tutorial_steps'


class Classifier extends Page
  el: $('.classifier')
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  subjectDimension: 440
  
  maxAnnotations: 5
  initialFetch: true
  
  elements:
    '[data-type="classified"]'  : 'nClassifiedEl'
    '[data-type="potentials"]'  : 'nPotentialsEl'
    '[data-type="favorites"]'   : 'nFavoritesEl'
    '.subjects'                 : 'subjectsEl'
  
  events:
    'click a[data-type="heart"]:nth(0)'   : 'onFavorite'
    'click a[data-type="finish"]:nth(0)'  : 'onFinish'
    'click .current .image svg'           : 'onAnnotation'
    'click circle'                        : 'onCircle'
  
  
  constructor: ->
    super
    @html @template
    
    @tutorial = new Tutorial
      parent: '.classifier'
      steps: TutorialSteps
    
    # Setup events
    User.on 'change', @onUserChange
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
  
  activate: ->
    super
    if @classification?
      if @classification.subject.tutorial
        @tutorial.start()
  
  onUserChange: (e, user) =>
    # Get the initial stack of subject
    Subject.next() if @initialFetch
    
    if user?
      project = user.project
      
      # Check if the tutorial subject is already loaded
      if @classification?.subject.tutorial?
        # End tutorial and move on to next subject if tutorial complete
        if project.tutorial_done?
          @tutorial.end()
          $('a[data-type="finish"]:nth(0)').click()
      
      @nClassified  = project.classification_count or 0
      @nPotentials  = project.annotation_count or 0
      @nFavorites   = project.favorite_count or 0
      
      @startTutorial() unless project.tutorial_done?
    else
      @nClassified  = 0
      @nPotentials  = 0
      @nFavorites   = 0
      
      @startTutorial()
    
    @setClassified()
    @setPotentials()
    @setFavorites()
  
  startTutorial: ->
    # Set the tutorial subject
    subject = new Subject
      id: '5101a1931a320ea77f000003'
      location:
        standard: 'images/tutorial-subject.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      # Spoofing data to test synthetic notification
      metadata:
        synthetic:
          # Types can be (0) double lensed quasar (1) quad lensed quasar (2) System of arcs around a cluster (3) No lens
          type: 0
          x: 0.5
          y: 0.5
      tutorial: true
      zooniverse_id: 'ASW0000001'
    
    @classification = new Classification {subject}
    
    # This code is getting messy.
    unless @initialFetch
      # Inject tutorial subject
      params =
        url: subject.location.standard
        zooId: subject.zooniverse_id
      @subjectsEl.prepend @subjectTemplate(params)
      # Move the current class
      @el.find('.current').removeClass('current')
      @el.find('.subject').first().addClass('current')
      @setCurrentSVG()
    @tutorial.start()
  
  onSubjectSelect: (e, subject) =>
    if @initialFetch
      for subject in Subject.instances
        params = 
          url: subject.location.standard
          zooId: subject.zooniverse_id
        @subjectsEl.append @subjectTemplate(params)
      @initialFetch = false
    else
      params =
        url: subject.location.standard
      @subjectsEl.append @subjectTemplate(params)
    
    # Reset variables
    @annotations      = {}
    @annotationIndex  = 0
    @warn             = true
    @hasAnnotation    = false
    @hasNotified      = false
    
    # Create new classification
    subject = Subject.first()
    @classification = new Classification {subject}
    
    # Update DOM
    @el.find('.subject').first().addClass('current')
    @setCurrentSVG()
  
  onNoMoreSubjects: ->
    alert "We've run out of subjects."
  
  setClassified: ->
    @nClassifiedEl.text(@nClassified)
  
  setPotentials: ->
    @nPotentialsEl.text(@nPotentials)
  
  setFavorites: ->
    @nFavoritesEl.text(@nFavorites)
  
  setCurrentSVG: ->
    svg = @el.find('.current').find('svg')
    @svg = svg
  
  onAnnotation: (e) ->
    
    # Create annotation and push to object
    x = e.offsetX
    y = e.offsetY
    annotation = new Annotation({el: @svg, x: x, y: y, index: @annotationIndex})
    @annotations[@annotationIndex] = annotation
    @annotationIndex += 1
    annotation.bind('remove', @removeAnnotation)
    annotation.bind('move', @checkProximity)
    
    # Replace text on interface
    unless @hasAnnotation
      @el.find('.current [data-type="finish"]').text('Finished marking!')
      @hasAnnotation = true
    
    # Update stats
    @nPotentials += 1
    @setPotentials()
    
    # Check proximity to synthetic
    @checkProximity(x, y)
    
    # Prompt message if too many annotations
    count = _.keys(@annotations).length
    return unless count + 1 > @maxAnnotations
    random = Math.random()
    if random < 0.1 and @warn
      @warn = false
      # TODO: Make this look nice.  Warn user of over marking if exceeding maxAnnotations
      alert("Whoa buddy!  Remember gravitional lenses are very rare astronomical objects.  There usually won't be this many interesting objects in an image.  If you think this is an exception, please discuss this image in Talk so that the science team can take a look!")
  
  removeAnnotation: (annotation) =>
    index = annotation.index
    delete @annotations[index]
    
    # Update stats
    @nPotentials -= 1
    @setPotentials()
    
    # Update finish text if necessary
    count = _.keys(@annotations).length
    if count is 0
      @el.find('.current [data-type="finish"]').text('Nothing interesting')
      @hasAnnotation = false
  
  checkProximity: (x, y) =>
    # Normalize coordinates
    x = x / @subjectDimension
    y = y / @subjectDimension
    
    synthetic = @classification.subject.metadata.synthetic
    if synthetic?
      type = synthetic.type
      syntheticX = synthetic.x
      syntheticY = synthetic.y
      isNear = @isNear(x, y, syntheticX, syntheticY)
      @notify(type) if isNear
  
  # Check if annotation is near synthetic object (L2)
  isNear: (x1, y1, x2, y2) ->
    xd = (x1 - x2) * (x1 - x2)
    yd = (y1 - y2) * (y1 - y2)
    d = Math.sqrt(xd + yd)
    console.log "d = ", d
    return if d < 0.1 then true else false
  
  notify: (type) ->
    unless @hasNotified
      console.log 'annotation is near synthetic'
      @hasNotified = true
  
  # Prevent annotations over SVG elements
  onCircle: (e) -> e.stopPropagation()
  
  onFavorite: (e) ->
    e.preventDefault()
    if User.current?
      el = $(e.currentTarget).find('.icon')
      if el.hasClass('active')
        el.removeClass('active')
        @classification.favorite = false
        @nFavorites -= 1
      else
        el.addClass('active')
        @classification.favorite = true
        @nFavorites += 1
      @setFavorites()
    else
      alert ("Please sign in or make an account to save favourites.")
  
  onFinish: (e) ->
    e.preventDefault()
    
    # Process annotations and push to API
    for index, annotation of @annotations
      @classification.annotate(annotation.toJSON())
    @classification.send()
    
    # Get DOM elements
    target  = $(e.currentTarget)
    current = $('.current')
    next    = current.siblings().first()
    
    # Change classes
    current.removeClass('current')
    current.addClass('removing')
    next.removeClass('right')
    
    # Remove subject from DOM and request next subject
    setTimeout ->
      current.remove()
      Subject.next()
    , 400
    
    # Update stats
    @nClassified += 1
    @setClassified()


module.exports = Classifier