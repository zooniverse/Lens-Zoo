
_     = require 'underscore/underscore'

User            = require 'zooniverse/models/user'
Subject         = require 'zooniverse/models/subject'
Favorite        = require 'zooniverse/models/favorite'
Classification  = require 'models/classification'

Page          = require 'controllers/page'
Annotation    = require 'controllers/Annotation'
Viewer        = require 'controllers/viewer'
{Tutorial}    = require 'zootorial'

TutorialSteps     = require 'lib/tutorial_steps'
TutorialCallbacks = require 'lib/TutorialCallbacks'


class Classifier extends Page
  @include TutorialCallbacks
  
  el: $('.classifier')
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  subjectDimension: 440
  
  maxAnnotations: 5
  initialFetch: true
  panKey: false
  
  elements:
    '[data-type="classified"]'  : 'nClassifiedEl'
    '[data-type="potentials"]'  : 'nPotentialsEl'
    '[data-type="favorites"]'   : 'nFavoritesEl'
    '.mask'                     : 'maskEl'
    '.viewer'                   : 'viewerEl'
    '.subjects'                 : 'subjectsEl'
    'svg.primary'               : 'svg'
  
  events:
    'click a[data-type="heart"]:nth(0)'       : 'onFavorite'
    'click a[data-type="dashboard"]:nth(0)'   : 'onDashboard'
    'click a[data-type="finish"]:nth(0)'      : 'onFinish'
    'click svg.primary'                       : 'onAnnotation'
    'click circle'                            : 'onCircle'
    'click .mask'                             : 'onViewerClose'
  
  
  constructor: ->
    super
    @html @template
    
    @reset()
    
    # Initialize controller for WebFITS
    @viewer = new Viewer({el: @el.find('.viewer')[0], classifier: @})
    
    # Setup events
    @bind 'start', @start
    @bind 'tutorial', @startTutorial
    
    User.on 'change', @onUserChange
    @viewer.bind 'ready', @setupMouseControls
    @viewer.bind 'close', @onViewerClose
  
  # Reset variables for a classification
  reset: ->
    console.log 'reset'
    
    @annotations      = {}
    @annotationIndex  = 0
    @warn             = true
    @hasAnnotation    = false
    @hasNotified      = false
  
  onUserChange: (e, user) =>
    console.log 'onUserChange'
    
    @nClassified  = 0
    @nPotentials  = 0
    @nFavorites   = 0
    
    if user?
      project = user.project
      unless 'tutorial_done' of project
        @trigger 'tutorial'
      else
        @nClassified  = project.classification_count or 0
        @nPotentials  = project.annotation_count or 0
        @nFavorites   = project.favorite_count or 0
        @trigger 'start'
    else
      @trigger 'tutorial'
    @setClassified()
    @setPotentials()
    @setFavorites()
  
  start: ->
    console.log 'start'
    
    # Set up events
    Subject.on 'fetch', @onFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Initial fetch for subjects
    Subject.next()
  
  startTutorial: ->
    console.log 'startTutorial'
    
    # Create tutorial object
    @tutorial = new Tutorial
      parent: '.classifier'
      steps: TutorialSteps
      
    # Cache for binding events
    @tutorialEl = @tutorial.dialog.el
    
    # Set queue length on Subject
    Subject.queueLength = 2
    
    # Bind tutorial-specific events
    Subject.on 'fetch', @createStagedTutorial
    Subject.fetch()
    
    # Set up tutorial-specific events
    @tutorialEl.bind 'start-tutorial', @onTutorialStart
    @tutorialEl.bind 'enter-tutorial-step', @onTutorialStep
    @tutorialEl.bind 'complete-tutorial', @onTutorialComplete
    @tutorialEl.bind 'end-tutorial', @onTutorialEnd
    
    # Set the tutorial subject
    subject = new Subject
      id: '5101a1931a320ea77f000003'
      location:
        standard: 'images/tutorial/tutorial-subject.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      # Spoofing data to test synthetic notification
      metadata:
        synthetic:
          # Types can be (0) double lensed quasar (1) quad lensed quasar (2) System of arcs around a cluster (3) No lens
          type: 3
          x: 0.5
          y: 0.5
      tutorial: true
      zooniverse_id: 'ASW0000001'
    
    # Create classification object
    @classification = new Classification {subject}
    
    # Append to DOM
    params =
      url: subject.location.standard
      zooId: subject.zooniverse_id
    @subjectsEl.prepend @subjectTemplate(params)
    @el.find('.current').removeClass('current')
    @el.find('.subject').first().addClass('current')
    
    @tutorial.start()
  
  createStagedTutorial: (e, subjects) =>
    console.log 'createStagedTutorial'
    
    # Handle event bindings
    Subject.off 'fetch', @createStagedTutorial
    Subject.on 'fetch', @onFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Create simulated subject
    simulatedSubject = new Subject
      id: '5101a1931a320ea77f000004'
      location:
        standard: 'images/tutorial/tutorial-subject.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      # Spoofing data to test synthetic notification
      metadata:
        synthetic:
          # Types can be (0) double lensed quasar (1) quad lensed quasar (2) System of arcs around a cluster (3) No lens
          type: 3
          x: 0.5
          y: 0.5
      tutorial: true
      zooniverse_id: 'ASW0000002'
    
    # Create blank subject
    blankSubject = new Subject
      id: '5101a1931a320ea77f000005'
      location:
        standard: 'images/tutorial/tutorial-subject.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      # Spoofing data to test synthetic notification
      metadata:
        synthetic:
          # Types can be (0) double lensed quasar (1) quad lensed quasar (2) System of arcs around a cluster (3) No lens
          type: 3
          x: 0.5
          y: 0.5
      tutorial: true
      zooniverse_id: 'ASW0000003'
    
    # Set queue length on Subject back to five
    Subject.queueLength = 5
    
    # Rearrange subjects (random, simulated, random, blank)
    Subject.instances[2] = simulatedSubject
    Subject.instances[3] = subjects[1]
    
    for subject, index in Subject.instances
      continue if index is 0
      params = 
        url: subject.location.standard
        zooId: subject.zooniverse_id
      @subjectsEl.append @subjectTemplate(params)
  
  # Append subject(s) to DOM when received
  onFetch: (e, subjects) =>
    console.log 'onFetch'
    
    for subject, index in subjects
      params = 
        url: subject.location.standard
        zooId: subject.zooniverse_id
      @subjectsEl.append @subjectTemplate(params)
  
  onSubjectSelect: (e, subject) =>
    console.log 'onSubjectSelect'
    
    @reset()
    
    # Create new classification
    @classification = new Classification {subject}
    
    # Update DOM
    @el.find('.subject').first().addClass('current')
  
  onNoMoreSubjects: ->
    console.log 'onNoMoreSubjects'
    
    alert "We've run out of subjects."
  
  setClassified: ->
    @nClassifiedEl.text(@nClassified)
  
  setPotentials: ->
    @nPotentialsEl.text(@nPotentials)
  
  setFavorites: ->
    @nFavoritesEl.text(@nFavorites)
  
  onAnnotation: (e) ->
    console.log 'onAnnotation'
    return if @panKey
    
    # Create annotation and push to object
    x = e.offsetX
    y = e.offsetY
    annotation = new Annotation({el: @svg, x: x, y: y, index: @annotationIndex})
    @annotations[@annotationIndex] = annotation
    @annotationIndex += 1
    annotation.bind('remove', @removeAnnotation)
    annotation.bind('move', @checkProximity)
    
    # Trigger event with annotation object
    @trigger 'onAnnotation', annotation
    
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
    console.log 'removeAnnotation'
    
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
  
  # Add to favorites and increment counter
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
  
  # Set up inline dashboard with current subject
  onDashboard: (e) ->
    e.preventDefault()
    
    # Show mask and viewer
    @maskEl.addClass('show')
    @viewerEl.addClass('show')
    
    # Load current subject
    @viewer.load(@classification.subject.metadata.id)
  
  # Enabled only when viewer is ready
  wheelHandler: (e) =>
    e.preventDefault()
    return if @panKey
    
    # Cache WebFITS object and push event
    wfits = @viewer.wfits
    wfits.wheelHandler(e)
    
    # Get control parameters from WebFITS object
    halfWidth = wfits.width / 2
    halfHeight = wfits.height / 2
    zoom = wfits.zoom * halfWidth
    
    # Update Annotation attribute
    Annotation.zoom = zoom
    
    deltaX = halfWidth + Annotation.xOffset
    deltaY = halfHeight + Annotation.yOffset
    
    # Move element within zoom reference frame
    for key, a of @annotations
      x = (a.x + deltaX - halfWidth) * zoom + halfWidth
      y = (a.y - deltaY - halfHeight) * zoom + halfHeight
      a.gRoot.setAttribute("transform", "translate(#{x}, #{y})")
  
  # Called when viewer is ready
  setupMouseControls: (e) =>
    svg = @svg[0]
    
    # Update/reset Annotation class attributes
    Annotation.halfWidth = @viewer.wfits.width / 2
    Annotation.halfHeight = @viewer.wfits.height / 2
    Annotation.xOffset = @viewer.wfits.xOffset
    Annotation.yOffset = @viewer.wfits.yOffset
    
    # Setup mouse controls on the SVG element
    svg.addEventListener('mousewheel', @wheelHandler, false)
    
    # Set up pan key and mouse events
    $(document).keyup((e) => @panKey = false if e.keyCode is 32)
    $(document).keydown((e) =>
      e.preventDefault()
      @panKey = true if e.keyCode is 32
    )
    
    # Pass events to viewer if pan key is true
    svg.onmousedown = (e) =>
      @viewer.wfits.canvas.onmousedown(e) if @panKey
    svg.onmouseup = (e) =>
      @viewer.wfits.canvas.onmouseup(e) if @panKey
    svg.onmousemove = (e) =>
      if @panKey
        # Pass event to WebFITS object
        @viewer.wfits.canvas.onmousemove(e)
        
        if @viewer.wfits.drag
          # Update Annotation class attributes
          Annotation.xOffset = xOffset = @viewer.wfits.xOffset
          Annotation.yOffset = yOffset = @viewer.wfits.yOffset
          
          halfWidth = Annotation.halfWidth
          halfHeight = Annotation.halfHeight
          zoom = Annotation.zoom
          
          # Translate origin
          deltaX = halfWidth + xOffset
          deltaY = halfHeight + yOffset
          
          # Move element within pan-zoom reference frame
          for key, a of @annotations
            x = (a.x + deltaX - halfWidth) * zoom + halfWidth
            y = (a.y - deltaY - halfHeight) * zoom + halfHeight
            
            a.gRoot.setAttribute("transform", "translate(#{x}, #{y})")
          
    svg.onmouseout = (e) =>
      @viewer.wfits.canvas.onmouseout(e) if @panKey
    svg.onmouseover = (e) =>
      @viewer.wfits.canvas.onmouseover(e) if @panKey
  
  onViewerClose: (e) =>
    @maskEl.removeClass('show')
    @viewerEl.removeClass('show')
    
    # Reset Annotation attributes
    Annotation.xOffset = -220.5
    Annotation.yOffset = -220.5
    
    # Reset the annotation positions
    for key, a of @annotations
      a.gRoot.setAttribute("transform", "translate(#{a.x}, #{a.y})")
    
    # Tear down mouse events
    $(document).keyup(null)
    $(document).keydown(null)
    
    svg = @svg[0]
    svg.removeEventListener('mousewheel', @wheelHandler, false)
    svg.onmousedown = null
    svg.onmouseup   = null
    svg.onmousemove = null
    svg.onmouseout  = null
    svg.onmouseover = null
    
    @viewer.teardown()
  
  onFinish: (e) ->
    console.log 'onFinish'
    
    e.preventDefault()
    
    # Process annotations and push to API
    for index, annotation of @annotations
      @classification.annotate(annotation.toJSON())
    @classification.send()
    
    # Empty SVG element
    @svg.empty()
    
    # Clear viewer cache
    @viewer.clearCache()
    
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