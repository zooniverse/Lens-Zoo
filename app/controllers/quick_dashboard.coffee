
{Controller}  = require 'spine'
browserDialog = require 'zooniverse/controllers/browser-dialog'
{Dialog}      = require 'zootorial'


class QuickDashboard extends Controller
  dimension: 441
  bands:  ['g', 'r', 'i']
  source: 'http://spacewarps.org/subjects/raw/'

  cache: {}
  prefix: null

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
    # Get the browser vendor and version
    userAgent = browserDialog.testAgent(navigator.userAgent)

    unless (DataView?)
      alert 'Sorry, your browser does not support features needed for this tool.'
      return

    # Determine if WebGL is supported, otherwise fall back to canvas
    canvas  = document.createElement('canvas')
    for name in ['webgl', 'experimental-webgl']
      try
        context = canvas.getContext(name)

        # Check if browser support floating-point textures
        ext = context.getExtension('OES_texture_float')

      catch error
        continue
      break if context?

    lib = if context? then 'gl' else 'canvas'

    # Default to canvas if browser does not support WebGL floating-point texture extension
    lib = if ext? then 'gl' else 'canvas'

    # Default to canvas if Safari regardless of WebGL
    lib = 'canvas' if userAgent.browser is 'safari'

    # Load appropriate WebFITS library asynchronously
    url = "javascripts/webfits-#{lib}.js"
    $.getScript(url, =>
      @dfs.webfits.resolve()
    )
    # Load fitsjs asynchronously
    $.getScript("javascripts/fits.js", =>
      @dfs.fitsjs.resolve()
    )

  load: (prefix) ->
    @prefix = prefix

    # Add loading class
    $('.mask').addClass('loading')

    # Setup WebFITS object
    @wfits = new astro.WebFITS(@el.find('.webfits')[0], @dimension)
    @wfits.setupControls()

    # Create new deferreds for each channel
    for band in @bands
      @dfs[band] = new $.Deferred()

    # Create deferred and set up callback for error handling
    errDfd = new $.Deferred()

    $.when(errDfd)
      .done(@onError)

    # Set callback for when all channels and astrojs libraries received
    dfs = $.map(@dfs, (v, k) -> v)
    $.when.apply(null, dfs)
      .done(@allChannelsReceived)

    if 'prefix' of @cache and Object.keys(@cache.prefix).length > 0
      cache = @cache['prefix']

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
      @cache['prefix'] = {}
      for band, index in @bands
        do (band, index) =>

          path = "#{@source}#{prefix}_#{band}.fits.fz"
          new astro.FITS.File(path, (fits) =>
            if fits is null
              errDfd.resolve()
              return

            @cache['prefix'][band] = {}

            hdu = fits.getHDU()
            header = hdu.header
            dataunit = hdu.data

            arr = dataunit.getFrame(0)
            [min, max] = dataunit.getExtent(arr)
            width = dataunit.width
            height = dataunit.height
            calibration = @getCalibration(header)

            @calibrations[band] = calibration
            @wfits.loadImage(band, arr, width, height)

            # Cache some data
            @cache['prefix'][band].min = min
            @cache['prefix'][band].max = max
            @cache['prefix'][band].arr = arr
            @cache['prefix'][band].width = width
            @cache['prefix'][band].height = height
            @cache['prefix'][band].calibration = calibration

            @dfs[band].resolve()
          )

  onError: =>
    @trigger 'close'
    errorDialog = new Dialog
      content: "Oh no! We had trouble getting the data. Try the Quick Dashboard on the next image."
      attachment: 'center center .annotation center center'
    errorDialog.open()

  # NOTE: Using exposure time = 1.0
  getCalibration: (header) ->
    zeroPoint = header.get('MZP_AB') or header.get('PHOT_C')
    return Math.pow(10, zeroPoint - 30.0)

  # Call when all channels are received (i.e. each deferred is resolved)
  allChannelsReceived: =>

    # Remove loading class
    $('.mask').removeClass('loading')

    # Setup callback for escape key
    document.onkeydown = (e) =>
      if e.keyCode is 27
        @trigger 'close'

        # Remove the callback
        document.onkeydown = null

    @append("""
      <div class='viewer-tools'>
        <div class='controls'>
          <a title='See the same view as on the main interface.' href='' data-preset='0'>Standard</a>
          <a title="Turn down the yellow galaxies’ brightness" href='' data-preset='1'>Brighter</a>
          <a title='Turn up the brightness of the faintest objects' href='' data-preset='2'>Bluer</a>
          <a title='Back to main interface' href='' data-preset='finished'>Return</a>
        </div>
        <div class='flag'>?</div>
        <div class='instructions'>Scroll to zoom.  Drag to move around the image.</div>
        <div class='download'>
          Download Data:
          <a href='#{@source}#{@prefix}_u.fits.fz'>u</a>
          <a href='#{@source}#{@prefix}_g.fits.fz'>g</a>
          <a href='#{@source}#{@prefix}_r.fits.fz'>r</a>
          <a href='#{@source}#{@prefix}_i.fits.fz'>i</a>
          <a href='#{@source}#{@prefix}_z.fits.fz'>z</a>
        </div>
      </div>
      """
    )
    @el.find('a[data-preset="0"]').click()
    @trigger "ready"

  onParameterChange: (e) =>
    e.preventDefault()

    @presetEl.removeClass('selected')
    $(e.currentTarget).addClass('selected')

    preset = e.currentTarget.dataset.preset
    if preset is 'finished'
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
    @wfits?.teardown()
    @wfits = undefined
    @prefix = null
    @el.find('.viewer-tools').remove()

  clearCache: ->
    for key, value of @cache
      delete @cache[key]


module.exports = QuickDashboard
