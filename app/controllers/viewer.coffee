
{Controller} = require 'spine'


class Viewer extends Controller
  template: require 'views/viewer'
  dimension: 441
  
  bands:  ['g', 'r', 'i']
  # TODO: Update when FITS images find permanent home
  source: 'http://www.spacewarps.org.s3.amazonaws.com/beta/subjects/raw/'
  
  # Default parameter values
  defaultAlpha: 0.09
  defaultQ: 1.7
  defaultScales: [0.4, 0.6, 1.7]
  
  cache: {}
  
  # TODO: Get three presets from science team
  parameters:
    0:
      alpha: 0.09
      Q: 1.0
      scales: [0.4, 0.6, 1.7]
    1:
      alpha: 0.17
      Q: 1.0
      scales: [0.4, 0.6, 1.7]
    2:
      alpha: 0.11
      Q: 2
      scales: [0.4, 0.6, 2.5]
  
  events:
    'click a[data-preset]'  : 'onParameterChange'
  
  elements:
    'a[data-preset]'  : 'presetEl'
  
  constructor: ->
    super
    
    @calibrations = {}
    @dfs =
      webfits: new $.Deferred()
      fitsjs: new $.Deferred()
    
    @getApi()
  
  getApi: ->
    unless DataView?
      alert 'Sorry, your browser does not support features needed for this tool.'

    # Determine if WebGL is supported, otherwise fall back to canvas
    canvas  = document.createElement('canvas')
    context = canvas.getContext('webgl')
    context = canvas.getContext('experimental-webgl') unless context?

    # Load appropriate WebFITS library asynchronously
    lib = if context? then 'gl' else 'canvas'
    url = "javascripts/webfits-#{lib}.js"
    $.getScript(url, =>
      @dfs.webfits.resolve()
    )
    
    # Load fitsjs asynchronously
    $.getScript("javascripts/fits.js", =>
      @dfs.fitsjs.resolve()
    )
  
  load: (prefix) ->
    
    # Setup WebFITS object
    @wfits = new astro.WebFITS(@el.find('.webfits')[0], @dimension)
    @wfits.setupControls()
    
    # Create new deferreds for each channel
    for band in @bands
      @dfs[band] = new $.Deferred()
    
    # Set callback for when all channels and astrojs libraries received
    dfs = $.map(@dfs, (v, k) -> v)
    $.when.apply(null, dfs)
      .done(@allChannelsReceived)
    
    # Check cache for data
    if prefix of @cache
      cache = @cache[prefix]
      
      # Load files from cache
      for band, index in @bands
        do (band, index) =>
          min = cache[band].min
          max = cache[band].max
          arr = cache[band].arr
          width = cache[band].width
          height = cache[band].height
          @calibrations[band] = cache[band].calibration
          
          @wfits.loadImage(band, arr, width, height)
          @dfs[band].resolve()
    else
      # Request from remote source
      @cache[prefix] = {}
      for band, index in @bands
        do (band, index) =>
          @cache[prefix][band] = {}
          path = "#{@source}#{prefix}_#{band}.fits.fz"
        
          new astro.FITS.File(path, (fits) =>
            hdu = fits.getHDU()
            header = hdu.header
            dataunit = hdu.data
          
            # Get image data
            dataunit.getFrameAsync(0, (arr) =>
              [min, max] = dataunit.getExtent(arr)
              width = dataunit.width
              height = dataunit.height
              calibration = @getCalibration(header)
              
              @calibrations[band] = calibration
              @wfits.loadImage(band, arr, width, height)
              
              # Cache some data
              @cache[prefix][band].min = min
              @cache[prefix][band].max = max
              @cache[prefix][band].arr = arr
              @cache[prefix][band].width = width
              @cache[prefix][band].height = height
              @cache[prefix][band].calibration = calibration
              
              @dfs[band].resolve()
            )
          )
  
  # NOTE: Using exposure time = 1.0
  getCalibration: (header) ->
    zeroPoint = header.get('MZP_AB') or header.get('PHOT_C')
    return Math.pow(10, zeroPoint - 30.0)
  
  # Call when all channels are received (i.e. each deferred is resolved)
  allChannelsReceived: =>
    # Setup callback for escape key
    document.onkeydown = (e) =>
      if e.keyCode is 27
        @trigger 'close'
        
        # Remove the callback
        document.onkeydown = null
    @append("""
      <div class='controls'>
        <a href='' data-preset='0'>Standard</a>
        <a href='' data-preset='1'>Brighter</a>
        <a href='' data-preset='2'>Bluer</a>
        <a href='' data-preset='finished'>Return</a>
      </div>"""
    )
    @el.find('a[data-preset="0"]').click()
    @trigger "ready"
  
  onParameterChange: (e) =>
    e.preventDefault()
    
    @presetEl.removeClass('selected')
    $(e.currentTarget).addClass('selected')
    
    preset = e.currentTarget.dataset.preset
    if preset is 'finished'
      @classifier.onViewerClose()
      @trigger 'close'
      return
    
    # Pass preset to classifier so it can be stored on annotation
    @classifier.preset = preset
    
    # Get a preset and apply to color composite
    parameters = @parameters[preset]
    @wfits.setCalibrations(1, 1, 1)
    @wfits.setScales.apply(@wfits, parameters.scales)
    @wfits.setAlpha(parameters.alpha)
    @wfits.setQ(parameters.Q)
    @wfits.drawColor('i', 'r', 'g')
  
  teardown: =>
    @wfits.teardown()
    @wfits = undefined
    @el.find('.controls').remove()
  
  clearCache: ->
    for key, value of @cache
      delete @cache[key]


module.exports = Viewer