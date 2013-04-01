
_     = require 'underscore/underscore'

User            = require 'zooniverse/models/user'
Subject         = require 'zooniverse/models/subject'
Favorite        = require 'zooniverse/models/favorite'
Classification  = require 'models/classification'

Page          = require 'controllers/page'
Annotation    = require 'controllers/Annotation'
Viewer        = require 'controllers/viewer'
QuickGuide    = require 'controllers/quick_guide'

{Tutorial}    = require 'zootorial'
{Dialog}      = require 'zootorial'
{Step}        = require 'zootorial'

TutorialSteps = require 'lib/tutorial_steps'


class Classifier extends Page
  el: $('.classifier')
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  subjectDimension: 440
  
  maxAnnotations: 5
  initialFetch: true
  xDown: null
  yDown: null
  toAnnotate: true
  isTrainingSubject: false
  
  subjectGroup: '5154a3783ae74086ab000001'
  simulationGroup: '5154a3783ae74086ab000002'
  simRatio: 2 # Default to sending one simulation for every two subjects
  
  
  elements:
    '[data-type="classified"]'  : 'nClassifiedEl'
    '[data-type="potentials"]'  : 'nPotentialsEl'
    '[data-type="favorites"]'   : 'nFavoritesEl'
    '[data-type="sim-freq"]'    : 'simFrequency'
    '.mask'                     : 'maskEl'
    '.viewer'                   : 'viewerEl'
    '.subjects'                 : 'subjectsEl'
    'svg.primary'               : 'svg'
  
  events:
    'click a[data-type="heart"]:nth(0)'       : 'onFavorite'
    'click a[data-type="dashboard"]:nth(0)'   : 'onDashboard'
    'click a[data-type="finish"]:nth(0)'      : 'onFinish'
    'click svg.primary'                       : 'onAnnotation'
    'click g'                                 : 'stopPropagation'
    'click .mask'                             : 'onViewerClose'
  
  
  constructor: ->
    super
    @html @template
    
    # Initialize QuickGuide
    @quickGuide = new QuickGuide({el: @el.find('.quick-guide')})
    
    # Initialize controller for WebFITS
    @viewer = new Viewer({el: @el.find('.viewer')[0], classifier: @})
    
    # Setup events
    @bind 'start', @start
    @bind 'tutorial', @startTutorial
    
    User.on 'change', @onUserChange
    @viewer.bind 'ready', @setupMouseControls
    @viewer.bind 'close', @onViewerClose
    
    # Dialog for warning of over excessive annotations
    @warningDialog = new Dialog
      content: "That's a lot of markers! Remember, lenses are rare."
      attachment: 'center center svg.primary center center'
    
    @reset()
    
    # Start with subject group
    Subject.group = @subjectGroup
  
  active: ->
    super
    $(window).resize()  # Trick zootorial to show when page is active.
  
  # Reset variables for a classification
  reset: ->
    @setSimulationRatio()
    
    @annotations      = {}
    @annotationIndex  = 0
    @annotationCount  = 0
    @warn             = true
    @hasAnnotation    = false
    @hasWarned        = false
    @preset           = null
    @feedback         = false
    @xDown            = null
    @yDown            = null
    @toAnnotate       = true
    
    @dashboardTutorial = false
    @isTrainingSubject = false
    @ctx = undefined
    
    @warningDialog.close()
  
  onUserChange: (e, user) =>
    
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
      console.log 'dashboard_tutorial_done', 'dashboard_tutorial_done' of project
      
      unless 'tutorial_dashboard' of project
        @trigger 'dashboard-tutorial'
    else
      @trigger 'tutorial'
    
    # Render counts to DOM
    @setClassified()
    @setPotentials()
    @setFavorites()
    @setSimulationRatio()
  
  start: ->
    # Set up events
    Subject.on 'fetch', @onFetch
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Initial fetch for subjects
    Subject.next()
  
  onTutorialComplete: (e) =>
    console.log 'onTutorialComplete'
  
  onTutorialEnd: (e) ->
    $("circle[r='50']").remove()
  
  startTutorial: =>
    # Create tutorial and bind to handlers
    @tutorial = new Tutorial
      id: 'tutorial'
      firstStep: 'welcome'
      steps: TutorialSteps
    @tutorial.el.bind('complete-tutorial', @onTutorialComplete)
    @tutorial.el.bind('end-tutorial', @onTutorialEnd)
    
    # Move tutorial to classifier div
    $("[class^='zootorial']").appendTo(@el)
    
    # Set queue length on Subject
    Subject.queueLength = 3
    
    # Bind tutorial-specific event
    Subject.on 'fetch', @createStagedTutorial
    
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
        id: 'CFHTLS_091_2130'
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
        id: 'CFHTLS_079_2328'
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
        id: 'CFHTLS_082_0054'
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
    
    # Prompt Dashboard message
    if @nClassified is 5
      tutorial = new Tutorial
        id: 'dashboard'
        firstStep: 'dashboard'
        steps:
          length: 1
          
          dashboard: new Step
            number: 1
            header: 'Quick Dashboard'
            details: 'As gravitationally lensed features can be faint and/or small, you can explore an image in more detail in the Quick Dashboard. Try clicking on this button.'
            attachment: 'center bottom [data-type="dashboard"] center -0.2'
            className: 'arrow-bottom'
            onEnter: ->
              $('.current .controls a[data-type="dashboard"]').addClass('hover')
            onExit: ->
              $('.current .controls a[data-type="dashboard"]').removeClass('hover')
            next:
              'click a': true
      tutorial.start()
    
    # Prompt Talk message
    if @nClassified is 7
      tutorial = new Tutorial
        id: 'talk'
        firstStep: 'talk'
        steps:
          length: 1
          
          talk: new Step
            number: 1
            header: 'Talk'
            details: 'Talk is a place to discuss the things you find with the rest of the Space Warps community: together we aim to build a catalog of new lenses, some of the rarest objects in the universe. If you have questions, the Science Team and other astronomers will help answer them. If you find something that looks interesting, come and show it to the group!'
            attachment: 'center bottom [data-type="talk"] center top'
            className: 'arrow-bottom'
            onEnter: ->
              $('.current .controls a[data-type="talk"]').addClass('hover')
            onExit: ->
              $('.current .controls a[data-type="talk"]').removeClass('hover')
            next:
              'click a': true
      tutorial.start()
      
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
    return unless @toAnnotate
    
    # Create annotation and push to object
    position = $('.subject.current .image').position()
    x = e.pageX - position.left
    y = e.pageY - position.top
    
    annotation = new Annotation({el: @svg, x: x, y: y, index: @annotationIndex})
    @annotations[@annotationIndex] = annotation
    @annotationIndex += 1
    @annotationCount += 1
    annotation.bind('remove', @removeAnnotation)
    
    # Trigger event with annotation object
    @trigger 'onAnnotation', annotation
    
    # Replace text on interface
    unless @hasAnnotation
      @el.find('.current [data-type="finish"]').text('Finished marking!')
      @hasAnnotation = true
    
    # Update stats
    if @annotationCount is 1
      @nPotentials += 1
      @setPotentials()
    
    # Warn of overmarking
    if @annotationCount > 5 and Math.random() > 0.4 and !@hasWarned
      @warningDialog.open()
      @hasWarned = true
  
  removeAnnotation: (annotation) =>
    
    # Remove event bindings
    annotation.unbind()
    
    index = annotation.index
    delete @annotations[index]
    
    # Update stats
    @annotationCount -= 1
    if @annotationCount is 0
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
    
    # Activate annotate flag
    @toAnnotate = false
    
    # Update/reset Annotation class attributes
    Annotation.halfWidth = @viewer.wfits.width / 2
    Annotation.halfHeight = @viewer.wfits.height / 2
    Annotation.xOffset = @viewer.wfits.xOffset
    Annotation.yOffset = @viewer.wfits.yOffset
    
    # Setup mouse controls on the SVG element
    svg.addEventListener('mousewheel', @wheelHandler, false)
    
    # Pass events to viewer if pan key is true
    svg.onmousedown = (e) =>
      
      # Store the down position for later comparison
      @xDown = e.pageX
      @yDown = e.pageY
      
      # TODO: Find more efficient way to do this
      for key, a of @annotations
        return if a.drag
      
      @viewer.wfits.canvas.onmousedown(e)
      
    svg.onmouseup = (e) =>
      
      # Propagate to annotation layer if down coordinates match up coordinates
      if @xDown is e.pageX and @yDown is e.pageY
        @toAnnotate = true
      else
        @toAnnotate = false
      return if @viewer.wfits.drag is false
      
      @viewer.wfits.canvas.onmouseup(e)
      
    svg.onmousemove = (e) =>
      # Pass event to WebFITS object
      @viewer.wfits.canvas.onmousemove(e)
      
      # TODO: Find more efficient way to do this
      for key, a of @annotations
        return if a.drag
      
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
      @viewer.wfits.canvas.onmouseout(e)
    svg.onmouseover = (e) =>
      @viewer.wfits.canvas.onmouseover(e)
  
  onViewerClose: (e) =>
    @maskEl.removeClass('show')
    @viewerEl.removeClass('show')
    
    # Allow annotation again
    @toAnnotate = true
    
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
  
  setSimulationRatio: ->
    @simRatio = Math.floor(@nClassified / 20) + 2
    Subject.group = if @nClassified % @simRatio is 0 then @simulationGroup else @subjectGroup
    @simFrequency.text("1 in #{@simRatio}")
  
  submit: (e) =>
    
    # Process annotations and push to API
    annotations = []
    for index, annotation of @annotations
      annotations.push annotation.toJSON()
    annotations.push {preset: @preset} if @preset?
    
    # Process completion of dashboard tutorial
    annotations.push {dashboard_tutorial: @dashboardTutorial} if @dashboardTutorial
    
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
    
    if @isTrainingSubject
      
      # Move to the next image if user clicks finished again
      if @feedback
        @tutorial.close()
        @submit(e)
        return
      
      @feedback = true
      
      # Get the training type (e.g. lens or empty)
      trainingType = @classification.subject.metadata.training.type
      
      if trainingType in ['lens', 'lensed galaxy', 'lensed quasar']
        
        # Check if any annotation over lens
        over = false
        for index, annotation of @annotations
          over = @checkImageMask(annotation.x, annotation.y)
          break if over
        
        if over
          @tutorial = new Tutorial
            id: 'sim-found'
            firstStep: 'found'
            steps:
              length: 1

              found: new Step
                header: 'Nice catch!'
                details: "You found a simulated #{trainingType}!"
                attachment: 'center center .primary center center'
                blocks: '.primary .controls'
                nextButton: 'Next image'
                next: true
                onExit: =>
                  @submit(e)
          @tutorial.start()
        else
          @tutorial = new Tutorial
            id: 'sim-missed'
            firstStep: 'missed'
            steps:
              length: 1

              missed: new Step
                number: 1
                header: 'Whoops!'
                details: "You missed a simulated #{trainingType}!  Don't worry, let's move to the next image."
                attachment: 'center center .primary center center'
                blocks: '.primary .controls'
                nextButton: 'Next image'
                next: true
                onExit: =>
                  @submit(e)
          @tutorial.start()
        
      else
        # Subject is an empty field
        nAnnotations = Object.keys(@annotations).length
        if nAnnotations > 0
          @tutorial = new Tutorial
            id: 'empty-missed'
            firstStep: 'missed'
            steps:
              length: 1
              
              missed: new Step
                header: 'Whoops!'
                details: 'This field has no gravitional lens.'
                attachment: 'center center .primary center center'
                blocks: '.primary'
                nextButton: 'Next image'
                next: true
                onExit: =>
                  @submit(e)
          @tutorial.start()
        else
          @tutorial = new Tutorial
            id: 'empty-found'
            firstStep: 'found'
            steps:
              length: 1
              
              found: new Step
                header: 'Nice!'
                details: 'This field has no gravitional lens.'
                attachment: 'center center .primary center center'
                blocks: '.primary'
                nextButton: 'Next image'
                next: true
                onExit: =>
                  @submit(e)
          @tutorial.start()
    else
      @submit(e)


module.exports = Classifier