
_     = require 'underscore/underscore'

User            = require 'zooniverse/models/user'
Subject         = require 'zooniverse/models/subject'
Favorite        = require 'zooniverse/models/favorite'
Classification  = require 'models/classification'

Page        = require 'controllers/page'
Annotation  = require 'controllers/Annotation'
Viewer      = require 'controllers/viewer'
QuickGuide  = require 'controllers/quick_guide'

{Tutorial}  = require 'zootorial'
{Dialog}    = require 'zootorial'
{Step}      = require 'zootorial'

TutorialSubject   = require 'lib/tutorial_subject'
TutorialSteps     = require 'lib/tutorial_steps'
TutorialDashboard = require 'lib/tutorial_dashboard'
TutorialTalk      = require 'lib/tutorial_talk'

CreateFeedback  = require 'lib/create_feedback'


class Classifier extends Page
  @include CreateFeedback
  
  el: $('.classifier')
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  subjectDimension: 440
  dashboardCollection: 'Dashboard'
  
  maxAnnotations: 5
  
  subjectGroup: '5154a3783ae74086ab000001'
  simulationGroup: '5154a3783ae74086ab000002'
  
  
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
    'click g'                                 : 'stopPropagation'
  
  
  constructor: ->
    super
    
    @html @template
    
    # Initialize QuickGuide and FITS Viewer
    @quickGuide = new QuickGuide({el: @el.find('.quick-guide')})
    @viewer = new Viewer({el: @el.find('.viewer')[0], classifier: @})
    
    User.on 'change', @onUserChange
    @viewer.bind 'ready', @setupMouseControls
    @viewer.bind 'close', @onViewerClose
    
    # Dialog for warning of over excessive annotations
    @warningDialog = new Dialog
      content: "That's a lot of markers! Remember, lenses are rare."
      attachment: 'center center .annotation center center'
    
    # Reset variables before new classification
    @reset()
    
    # Start with subject group
    Subject.group = @subjectGroup
  
  active: ->
    super
    
    # Trick zootorial to show when page is active.
    $(window).resize()
  
  # Reset variables for a classification
  reset: ->
    @setSimulationRatio()
    
    @annotations      = {}
    @annotationIndex  = 0
    @annotationCount  = 0
    @hasAnnotation    = false
    @hasWarned        = false
    @preset           = null
    @feedbackShown    = false
    @xDown            = null
    @yDown            = null
    @isAnnotatable    = true
    
    @isTrainingSubject = false
    @ctx = undefined
    
    @warningDialog.close()
  
  # Called when the user changes.  Lots going on here:
  # 1) Determine tutorial state
  # 2) Check talk collection
  # 3) Set user counters
  onUserChange: (e, user) =>
    
    # Reset subjects
    Subject.instances = []
    $('.subjects').empty()
    @svg.empty()
    Subject.off 'fetch', @appendSubjects
    Subject.off 'select', @onSubjectSelect
    Subject.off 'no-more', @onNoMoreSubjects
    
    # Unbind Talk event
    @unbind 'addToTalk'
    
    # Set default counts
    @nClassified  = 0
    @nPotentials  = 0
    @nFavorites   = 0
    
    if user?
      
      # Interact with Talk
      @getTalkCollections(user)
      
      @bind 'addToTalk', (zooniverseId) =>
        @addToTalkCollection(user, zooniverseId)
      
      project = user.project
      
      # Determine if tutorial completed
      unless 'tutorial_done' of project
        @startTutorial()
      else
        @nClassified  = project.classification_count or 0
        @nPotentials  = project.annotation_count or 0
        @nFavorites   = project.favorite_count or 0
        @start()
    else
      @startTutorial()
    
    # Render counts to DOM
    @setClassified()
    @setPotentials()
    @setFavorites()
    
    @setSimulationRatio()
  
  # List Talk collections owned by user
  getTalkCollections: (user) ->
    
    # Authentication appended to header
    auth = base64.encode("#{user.name}:#{user.api_key}")
    headers = {}
    headers['Authorization'] = "Basic #{auth}"
    
    # Send the request
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/users/collection_list",
      dataType: 'json',
      success: (collections, status, response) =>
        @setTalkCollection(user, collections)
      headers: headers
    })
  
  # Set a Quick Dashboard collection unless it exists
  setTalkCollection: (user, collections) =>
    
    # Check users collections for Quick Dashboard
    for collection in collections
      if collection.title is @dashboardCollection
        @collectionId = collection.zooniverse_id
        return
    
    # Authentication appended to header
    auth = base64.encode("#{user.name}:#{user.api_key}")
    headers = {}
    headers['Authorization'] = "Basic #{auth}"
    
    # Create collection for user
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/collections",
      type: 'POST',
      data: {subject_id: 'ASW0000001', title: @dashboardCollection, description: 'A collection of all Space Warp images examined in the Quick Dashboard.'},
      headers: headers,
      success: (collection, status, response) =>
        @collectionId = collection.zooniverse_id
    })
  
  # Add subject to Talk collection
  addToTalkCollection: (user, zooniverseId) =>
    
    # Authentication appended to header
    auth = base64.encode("#{user.name}:#{user.api_key}")
    headers = {}
    headers['Authorization'] = "Basic #{auth}"
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/collections/#{@collectionId}/add_subject",
      type: 'POST',
      data: {subject_id: zooniverseId},
      headers: headers,
    })
  
  start: ->
    # Set up events
    Subject.on 'fetch', @appendSubjects
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    @tutorial.end() if @tutorial?
    
    # Initial fetch for subjects
    Subject.next()
  
  onTutorialEnd: (e) ->
    $("circle[r='50']").remove()
  
  startTutorial: =>
    
    # Create tutorial and bind to handlers
    @tutorial = new Tutorial
      id: 'tutorial'
      firstStep: 'welcome'
      steps: TutorialSteps
      parent: @el[0]
    @tutorial.el.bind('end-tutorial', @onTutorialEnd)
    
    # Set first tutorial subject
    subject = TutorialSubject.main
    
    # Create classification object
    @classification = new Classification {subject}
    
    # Empty tutorial subject from queue
    Subject.instances = []
    
    # Set queue length on Subject
    Subject.queueLength = 3
    
    # Bind tutorial-specific event
    Subject.on 'fetch', @createStagedTutorial
    
    # Fetch subjects from API
    Subject.fetch()
    
    # Append tutorial subject to DOM
    @appendSubjects(null, [subject])
    @el.find('.current').removeClass('current')
    @el.find('.subject').first().addClass('current')
    
    @tutorial.start()
  
  # Set up the staged tutorial subjects.  This should only be run once.
  createStagedTutorial: (e, subjects) =>
    
    # Handle event bindings
    Subject.off 'fetch', @createStagedTutorial
    Subject.on 'fetch', @appendSubjects
    Subject.on 'select', @onSubjectSelect
    Subject.on 'no-more', @onNoMoreSubjects
    
    # Create simulated and empty tutorial subjects
    simSubject = TutorialSubject.simulated
    dudSubject = TutorialSubject.empty
    
    # Set queue length on Subject back to five
    Subject.queueLength = 5
    
    # Insert tutorial subjects into queue
    Subject.instances.splice(1, 0, simSubject)
    Subject.instances.splice(3, 0, dudSubject)
    
    # Append remaining subjects to DOM
    @appendSubjects(null, Subject.instances)
  
  #
  # Subject callbacks
  #
  
  # Append subject(s) to DOM
  appendSubjects: (e, subjects) =>
    for subject, index in subjects
      params = 
        url: subject.location.standard
        zooId: subject.zooniverse_id
      @subjectsEl.append @subjectTemplate(params)
  
  onSubjectSelect: (e, subject) =>
    
    # Reset classification variables
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
    if @nClassified is 3
      tutorial = new Tutorial
        id: 'dashboard'
        firstStep: 'dashboard'
        steps: TutorialDashboard
      tutorial.start()
    
    # NOTE: Disabling during beta
    # # Prompt Talk message
    # if @nClassified is 7
    #   tutorial = new Tutorial
    #     id: 'talk'
    #     firstStep: 'talk'
    #     steps: TutorialTalk
    #   tutorial.start()
      
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
    return unless @isAnnotatable
    
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
    if (@annotationCount > @maxAnnotations) and (Math.random() > 0.4) and (not @hasWarned)
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
      @el.find('.current [data-type="finish"]').text('No Lenses Here!')
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
    zoom = wfits.getZoom() * halfWidth
    
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
    @isAnnotatable = false
    
    # Update/reset Annotation class attributes
    Annotation.halfWidth = @viewer.wfits.width / 2
    Annotation.halfHeight = @viewer.wfits.height / 2
    Annotation.xOffset = @viewer.wfits.getXOffset()
    Annotation.yOffset = @viewer.wfits.getYOffset()
    
    # Setup mouse controls on the SVG element
    svg.addEventListener('mousewheel', @wheelHandler, false)
    svg.addEventListener('DOMMouseScroll', @wheelHandler, false)
    
    # Pass events to viewer
    svg.onmousedown = (e) =>
      
      # Store the down position for later comparison
      @xDown = e.pageX
      @yDown = e.pageY
      
      return if Annotation.drag
      
      @viewer.wfits.canvas.onmousedown(e)
      
    svg.onmouseup = (e) =>
      
      # Propagate to annotation layer if down coordinates match up coordinates
      if @xDown is e.pageX and @yDown is e.pageY
        @isAnnotatable = true
      else
        @isAnnotatable = false
      return if @viewer.wfits.drag is false
      
      @viewer.wfits.canvas.onmouseup(e)
      
    svg.onmousemove = (e) =>
      # Pass event to WebFITS object
      @viewer.wfits.canvas.onmousemove(e)
      
      return if Annotation.drag
      
      if @viewer.wfits.drag
        # Update Annotation class attributes
        Annotation.xOffset = xOffset = @viewer.wfits.getXOffset()
        Annotation.yOffset = yOffset = @viewer.wfits.getYOffset()
        
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
    @isAnnotatable = true
    
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
  
  # Training scheme using simulations and empty fields
  setSimulationRatio: ->
    if true
      # When duds are included in the @TrainingGroup, need to multiply @simratio by 2 to 
      baseLevel = Math.floor(@nClassified / 20) + 1
      @level = Math.min(baseLevel, 3)
      @simRatio = 1 / (5 * Math.pow(Math.sqrt(2), @level - 1))
      Subject.group = if @simRatio > Math.random() then @simulationGroup else @subjectGroup
      # console.log "#{@nClassified}, #{@level}, #{@simRatio}, #{Subject.group}"
    else
      # NOTE: This is the old scheme with fall off of 1 / x
      @simRatio = Math.floor(@nClassified / 20) + 2
      Subject.group = if @nClassified % @simRatio is 0 then @simulationGroup else @subjectGroup
      # console.log "#{@simRatio}, #{Subject.group}"
  
  submit: (e) =>
    
    # Process annotations and push to API
    for index, annotation of @annotations
      @classification.annotate annotation.toJSON()
    
    # Quick Dashboard was accessed
    if @preset?
      
      # Record the Quick Dashboard preset
      @classification.annotate {preset: @preset}
      
      # Push subject to Talk collection
      @trigger 'addToTalk', @classification.subject.zooniverse_id
      
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
      # If finished is clicked again move to the next image
      if @feedbackShown
        @tutorial?.end()
        return
      
      @feedbackShown = true
      
      # Get the training type (e.g. lens or empty)
      training = @classification.subject.metadata.training
      trainingType = training.type
      
      # TODO: Do we have more than these categories?
      if trainingType in ['lensed galaxy', 'lensed quasar']
        
        # Get the location for the dialog
        x = (training.x + 30) / @subjectDimension
        y = 1 - (training.y / @subjectDimension)
        
        # Check if any annotation over lens
        isLensMarked = false
        for index, annotation of @annotations
          isLensMarked = @checkImageMask(annotation.x, annotation.y)
          break if isLensMarked
        
        if isLensMarked
          @tutorial = @createSimulationFoundFeedback(e, trainingType, x, y)
        else
          @tutorial = @createSimulationMissedFeedback(e, trainingType, x, y)
        
      else if trainingType is 'empty'
        
        # Count the number of annotations
        nAnnotations = _.keys(@annotations).length
        
        @tutorial = if nAnnotations > 0 then @createDudMissedFeedback(e) else @createDudFoundFeedback(e)
      
      # Start the tutorial
      @tutorial.start()
      
    else
      @submit(e)


module.exports = Classifier