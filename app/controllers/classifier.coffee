
_     = require 'underscore/underscore'

User            = require 'zooniverse/models/user'
Subject         = require 'zooniverse/models/subject'
Favorite        = require 'zooniverse/models/favorite'
Classification  = require 'models/classification'

Page          = require 'controllers/page'
Annotation    = require 'controllers/Annotation'
Viewer        = require 'controllers/viewer'

{Tutorial}    = require 'zootorial'
{Dialog}      = require 'zootorial'

TutorialSteps           = require 'lib/tutorial_steps'
TutorialStepsTalk       = require 'lib/tutorial_steps_talk'
TutorialStepsDashboard  = require 'lib/tutorial_steps_dashboard'
TutorialStepsSimulation = require 'lib/tutorial_steps_simulation'
TutorialStepsEmpty      = require 'lib/tutorial_steps_empty'

TutorialStepsQuickDashboard = require 'lib/tutorial_steps_quick_dashboard'


class Classifier extends Page
  el: $('.classifier')
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  subjectDimension: 440
  
  maxAnnotations: 5
  initialFetch: true
  panKey: false
  isTrainingSubject: false
  
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
    'click circle'                            : 'stopPropagation'
    'click rect'                              : 'stopPropagation'
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
    @bind 'dashboard-tutorial', @setupDashboardTutorial
    
    User.on 'change', @onUserChange
    @viewer.bind 'ready', @setupMouseControls
    @viewer.bind 'close', @onViewerClose
  
  active: ->
    super
    $(window).resize()  # Trick zootorial to show when page is active.
  
  # Reset variables for a classification
  reset: ->
    @annotations      = {}
    @annotationIndex  = 0
    @warn             = true
    @hasAnnotation    = false
    @hasNotified      = false
    @preset           = null
    
    @isTrainingSubject = false
    @ctx = undefined
  
  onUserChange: (e, user) =>
    console.log 'onUserChange'
    
    # Set default counts
    @nClassified  = 0
    @nPotentials  = 0
    @nFavorites   = 0
    
    if user?
      project = user.project
      
      # Determine if main tutorial completed
      unless 'tutorial_done' of project
        @trigger 'tutorial'
      else
        @nClassified  = project.classification_count or 0
        @nPotentials  = project.annotation_count or 0
        @nFavorites   = project.favorite_count or 0
        @trigger 'start'
      
      # Determine if dashboard tutorial completed
      unless 'tutorial_dashboard' of project
        @trigger 'dashboard-tutorial'
    else
      @trigger 'tutorial'
    
    # Render counts to DOM
    @setClassified()
    @setPotentials()
    @setFavorites()
  
  start: ->
    # Set up events
    Subject.on 'fetch', @onFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Initial fetch for subjects
    Subject.next()
  
  setupDashboardTutorial: (e) =>
    # Setup event to invoke dashboard tutorial
    @dashboardSelector = 'a[data-type="dashboard"]:nth(0)'
    @el.delegate(@dashboardSelector, 'click', @onDashboardTutorial)
  
  onDashboardTutorial: (e) =>
    console.log 'onDashboardTutorial'
    @el.undelegate(@dashboardSelector, 'click', @onDashboardTutorial)
    
    # Create Dashboard tutorial
    @tutorial = new Tutorial
      parent: '.classifier'
      steps: TutorialStepsQuickDashboard
    @tutorial.start()
  
  onTalkTutorialFinish: (e) =>
    @tutorial.dialog.el.unbind()
    @tutorial = undefined
    $('.zootorial-dialog').remove()
    $('.current .icon[data-icon="discuss"]').css('background-position', '-38px -32px')
  
  onTalkTutorial: (e) =>
    e.preventDefault()
    
    # Create Talk tutorial
    @tutorial = new Tutorial
      parent: '.classifier'
      steps: TutorialStepsTalk
    @tutorial.dialog.el.bind 'complete-tutorial end-tutorial', @onTalkTutorialFinish
    $('.current .icon[data-icon="discuss"]').css('background-position', '-38px 4px')
    
    # Remove old delegate and add normal delegate back
    @el.undelegate(@finishSelector, 'click')
    @el.delegate(@finishSelector, 'click', @onFinish)
    
    @tutorial.start()
  
  setupTalkTutorial: (e) =>
    @onFinish(e)
    
    # Remove delegate so this function is run only once
    @el.undelegate(@finishSelector, 'click')
    @el.delegate(@finishSelector, 'click', @onTalkTutorial)
  
  onTutorialExit: (e) =>
    # Delegate events so that Talk tutorial does not appear
    @el.undelegate(@finishSelector, 'click')
    @el.delegate(@finishSelector, 'click', @onFinish)
    @tutorial.dialog.el.unbind()
    @tutorial.end()
    
    $('.zootorial-dialog').remove()
  
  startTutorial: =>
    
    # Trigger dashboard tutorial setup
    @trigger 'dashboard-tutorial'
    
    @finishSelector = 'a[data-type="finish"]:nth(0)'
    
    # Create tutorial object
    @tutorial = new Tutorial
      parent: '.classifier'
      steps: TutorialSteps
    @tutorial.dialog.el.bind 'exit-dialog', @onTutorialExit
    
    # Set queue length on Subject
    Subject.queueLength = 3
    
    # Bind tutorial-specific event
    Subject.on 'fetch', @createStagedTutorial
    
    # Delegate events for Talk tutorial
    @el.undelegate(@finishSelector, 'click')
    @el.delegate(@finishSelector, 'click', @setupTalkTutorial)
    
    # Set the tutorial subject
    subject = new Subject
      id: '5101a1931a320ea77f000003'
      location:
        standard: 'images/tutorial/tutorial-1.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'lens'
        id: 'CFHTLS_037_1973'
      tutorial: true
      zooniverse_id: 'ASW0000001'
    
    # Create classification object
    @classification = new Classification {subject}
    
    # Empty all subjects from queue
    Subject.instances = []
    
    # Fetch subjects from API
    Subject.fetch()
    
    # Append tutorial subject to DOM
    params =
      url: subject.location.standard
      zooId: subject.zooniverse_id
    @subjectsEl.prepend @subjectTemplate(params)
    @el.find('.current').removeClass('current')
    @el.find('.subject').first().addClass('current')
    
    @tutorial.start()
  
  # Set up the staged tutorial subjects.  This should only be run once.
  createStagedTutorial: (e, subjects) =>
    # Handle event bindings
    Subject.off 'fetch', @createStagedTutorial
    Subject.on 'fetch', @onFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Create simulated subject
    simulatedSubject = new Subject
      id: '5101a1931a320ea77f000004'
      location:
        standard: 'images/tutorial/tutorial-2.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'lens'
        id: 'CFHTLS_082_0178'
      tutorial: true
      zooniverse_id: 'ASW0000002'
    
    # Create empty subject
    emptySubject = new Subject
      id: '5101a1931a320ea77f000005'
      location:
        standard: 'images/tutorial/tutorial-3.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'empty'
        id: 'CFHTLS_082_0414'
      tutorial: true
      zooniverse_id: 'ASW0000003'
    
    # Set queue length on Subject back to five
    Subject.queueLength = 5
    
    # Rearrange subjects (random, simulated, random, empty)
    Subject.instances[1] = simulatedSubject
    Subject.instances[2] = subjects[1]
    Subject.instances[3] = emptySubject
    Subject.instances[4] = subjects[2]
    
    # Append remaining subjects to DOM
    for subject, index in Subject.instances
      params = 
        url: subject.location.standard
        zooId: subject.zooniverse_id
      @subjectsEl.append @subjectTemplate(params)
  
  #
  # Subject callbacks
  #
  
  # Append subject(s) to DOM when received
  onFetch: (e, subjects) =>
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
    
    # Check if training subject
    if subject.metadata.training?
      @isTrainingSubject = true
      
      # Set up offscreen canvas and cache the context
      canvas = document.createElement('canvas')
      @ctx = canvas.getContext('2d')
      img = new Image()
      img.onload = (e) =>
        canvas.width = img.width
        canvas.height = img.height
        @ctx.drawImage(img, 0, 0, img.width, img.height)
      img.src = $('.current .image img').attr('src')
  
  onNoMoreSubjects: ->
    alert "We've run out of subjects."
  
  #
  # Counter functions
  #
  
  setClassified: ->
    @nClassifiedEl.text(@nClassified)
  
  setPotentials: ->
    @nPotentialsEl.text(@nPotentials)
  
  setFavorites: ->
    @nFavoritesEl.text(@nFavorites)
  
  #
  # Annotation functions
  #
  
  onAnnotation: (e) ->
    return if @panKey
    
    # Create annotation and push to object
    # position = @svg.offset()
    # x = e.pageX - position.left
    # y = e.pageY - position.top
    x = e.offsetX
    y = e.offsetY
    
    annotation = new Annotation({el: @svg, x: x, y: y, index: @annotationIndex})
    @annotations[@annotationIndex] = annotation
    @annotationIndex += 1
    annotation.bind('remove', @removeAnnotation)
    
    # Trigger event with annotation object
    @trigger 'onAnnotation', annotation
    
    # Replace text on interface
    unless @hasAnnotation
      @el.find('.current [data-type="finish"]').text('Finished marking!')
      @hasAnnotation = true
    
    # Update stats
    @nPotentials += 1
    @setPotentials()
  
  removeAnnotation: (annotation) =>
    # Remove event bindings
    annotation.unbind()
    
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
  
  # Check if volunteer marked a simulated lens
  checkImageMask: (x, y) =>
    pixel = @ctx.getImageData(x, y, 1, 1)
    mask = pixel.data[3]
    return if mask is 255 then true else false
  
  # Prevent annotations over SVG elements
  stopPropagation: (e) ->
    e.stopPropagation()
  
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
  
  submit: (e) =>
    console.log 'submit'
    
    # Process annotations and push to API
    annotations = []
    for index, annotation of @annotations
      annotations.push annotation.toJSON()
    annotations.push {preset: @preset} if @preset?
    
    @classification.annotate(annotations)
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

  onFinish: (e) =>
    e.preventDefault()
    console.log 'onFinish'
    
    if @isTrainingSubject
      # Get the training type (e.g. lens or empty)
      trainingType = @classification.subject.metadata.training.type
      
      if trainingType is 'lens'
        
        # Setup simulation tutorial
        @tutorial = new Tutorial
          parent: '.classifier'
          steps: TutorialStepsSimulation
        @tutorial.dialog.el.one 'end-tutorial', @submit
        
        # Check if any annotation over lens
        over = false
        for index, annotation of @annotations
          over = @checkImageMask(annotation.x, annotation.y)
          break if over
        unless over
          @tutorial.steps[0].content = "Oh! There is a simulated lens in this image. Don't worry if you miss a few."
        @tutorial.start()
      else
        
        # Setup empty-image tutorial
        @tutorial = new Tutorial
          parent: '.classifier'
          steps: TutorialStepsEmpty
        @tutorial.dialog.el.one 'end-tutorial', @submit
        
        nAnnotations = Object.keys(@annotations).length
        if nAnnotations > 0
          @tutorial.steps[0].content = "Oh! There weren't any lenses in this image. Check the Spotter's Guide to learn more about lenses."
        
        @tutorial.start()
    else
      @submit(e)


module.exports = Classifier