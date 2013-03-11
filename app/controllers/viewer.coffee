
# TODO: Better interface for async requests

class Viewer extends Spine.Controller
  template: require 'views/viewer'
  dimension: 441
  
  bands:  ['g', 'r', 'i']
  source: 'http://www.spacewarps.org.s3.amazonaws.com/beta/subjects/raw/'
  
  # Default parameter values
  defaultAlpha: 0.09
  defaultQ: 1.7
  defaultScales: [0.4, 0.6, 1.7]
  
  parameters:
    0:
      alpha: 0.09
      Q: 1.7
      scales: [0.4, 0.6, 1.7]
    1:
      alpha: 0.2
      Q: 2.5
      scales: [0.4, 0.6, 1.7]
    2:
      alpha: 0.4
      Q: 5
      scales: [0.4, 0.6, 1.7]
  
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
    
    $.getScript("javascripts/fits.js", =>
      @dfs.fitsjs.resolve()
    )
    
  
  load: (prefix) ->
    @wfits = new astro.WebFITS(@el.find('.webfits')[0], @dimension)
    @wfits.setupControls()
    
    # Create new deferreds for each channel
    for band in @bands
      @dfs[band] = new $.Deferred()
    
    # Set callback for when all channels and astrojs libraries received
    dfs = $.map(@dfs, (v, k) -> v)
    $.when.apply(null, dfs)
      .done(@allChannelsReceived)
    
    for band, index in @bands
      do (band, index) =>
        path = "#{@source}#{prefix}_#{band}.fits.fz"
        
        new astro.FITS.File(path, (fits) =>
          hdu = fits.getHDU()
          header = hdu.header
          dataunit = hdu.data
          
          # Get image data
          dataunit.getFrameAsync(0, (arr) =>
            [min, max] = dataunit.getExtent(arr)
            @calibrations[band] = @getCalibration(header)
            @wfits.loadImage(band, arr, dataunit.width, dataunit.height)
            @dfs[band].resolve()
          )
        )
  
  # NOTE: Using exposure time = 1.0
  getCalibration: (header) ->
    zeroPoint = header.get('MZP_AB') or header.get('PHOT_C')
    return Math.pow(10, zeroPoint - 30.0)
  
  allChannelsReceived: =>
    # Setup callback for escape key
    document.onkeydown = (e) =>
      if e.keyCode is 27
        @trigger 'close'
        
        # Remove the callback
        document.onkeydown = null
    @append("""
      <div class='controls'>
        <a href='' data-preset='0'>Lens Type I</a>
        <a href='' data-preset='1'>Lens Type II</a>
        <a href='' data-preset='2'>Lens Type III</a>
        <a href='' data-preset='finished'>Nothing interesting</a>
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
      @classifier.el.find('a[data-type="finish"]:nth(0)').click()
      return
    
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
  
module.exports = Viewer