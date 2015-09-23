{Controller}  = require 'spine'
browserDialog = require 'zooniverse/controllers/browser-dialog'
{Dialog}      = require 'zootorial'

class QuickDashboard extends Controller
  dimension: 441
  source: 'http://spacewarps.org/subjects/raw/'

  cache: {}
  prefix: null

  # CFHTLS:
  bands: ['g', 'r', 'i']
  # VICS82:
  # bands:  ['i', 'J', 'Ks']

  parameters:

    # Old settings for CFHTLS images (no PROV keyword), for reference:
    0:
      alpha: 0.09
      Q: 1.0
      # scales: [0.4, 0.6, 1.7]
      scales: [1.7, 0.6, 0.4]
    1:
      alpha: 0.17
      Q: 1.0
      # scales: [0.4, 0.6, 1.7]
      scales: [1.7, 0.6, 0.4]
    2:
      alpha: 0.11
      Q: 2.0
      # scales: [0.4, 0.6, 2.5]
      scales: [2.5, 0.6, 0.4]

    # VICS82 VISTA IR data, PROV = 'V':
    # 0:
    #   alpha: 0.0040
    #   Q: 1.5
    #   scales: [1.0, 1.4, 2.0]
    # 1:
    #   alpha: 0.0080
    #   Q: 1.5
    #   scales: [1.0, 1.4, 2.0]
    # 2:
    #   alpha: 0.0060
    #   Q: 2.0
    #   scales: [1.0, 1.4, 4.0]

    # VICS82, CFHT IR data, PROV = 'C':
    # (If PROV keyword is 'C' then we'll add 3 to the value of preset)
    # 3:
    #   alpha: 0.0020
    #   Q: 1.5
    #   scales: [1.0, 1.4, 6.0]
    # 4:
    #   alpha: 0.0040
    #   Q: 1.5
    #   scales: [1.0, 1.4, 6.0]
    # 5:
    #   alpha: 0.0032
    #   Q: 2.0
    #   scales: [1.0, 1.4, 12.0]

  events:
    'click a[data-preset]'  : 'onParameterChange'

  elements:
    'a[data-preset]'  : 'presetEl'


  constructor: ->
    super

    @calibrations = {}
    @provenances = {}

    @dfs =
      webfits: new $.Deferred()
      fitsjs: new $.Deferred()

    url = "javascripts/webfits-canvas.js"
    $.getScript(url, =>
      @dfs.webfits.resolve()
    )

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
          # VICS82:
          # @provenances[band] = cache[band].provenance

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
            {width, height} = dataunit
            calibration = @getCalibration(header)
            # VICS82:
            # provenance = @getProvenance(header)

            @calibrations[band] = calibration
            # VICS82:
            # @provenances[band] = provenance
            @wfits.loadImage(band, arr, width, height)

            # Cache some data
            @cache['prefix'][band].min = min
            @cache['prefix'][band].max = max
            @cache['prefix'][band].arr = arr
            @cache['prefix'][band].width = width
            @cache['prefix'][band].height = height
            @cache['prefix'][band].calibration = calibration
            # VICS82:
            # @cache['prefix'][band].provenance = provenance

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
    # CFHTLS:
    zeroPoint = 30.0
    # VICS82:
    # zeroPoint = header.get('MZP_AB')
    return Math.pow(10, 0.4*(30.0 - zeroPoint))

  # VICS82:
  getProvenance: (header) ->
    return header.get('PROV')

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

    # CFHTLS
    @append("""
      <div class='viewer-tools'>
        <div class='controls'>
          <a title='See the same view as on the main interface.' href='' data-preset='0'>Standard</a>
          <a title="Turn down the bright galaxies' brightness" href='' data-preset='1'>Brighter</a>
          <a title='Turn up the brightness of the bluer objects' href='' data-preset='2'>Bluer</a>
          <a title='Back to main interface' href='' data-preset='finished'>Return</a>
        </div>
        <div class='flag'>?</div>
        <div class='instructions'>Scroll to zoom.  Drag to move around the image.</div>
        <div class='download'>
          Download Data:
          <a href='#{@source}#{@prefix}_g.fits.fz'>g</a>
          <a href='#{@source}#{@prefix}_r.fits.fz'>r</a>
          <a href='#{@source}#{@prefix}_i.fits.fz'>i</a>
        </div>
      </div>
      """
    )

    # VICS82:
    # @append("""
    #   <div class='viewer-tools'>
    #     <div class='controls'>
    #       <a title='See the same view as on the main interface.' href='' data-preset='0'>Standard</a>
    #       <a title="Turn down the bright galaxies' brightness" href='' data-preset='1'>Brighter</a>
    #       <a title='Turn up the brightness of the bluer objects' href='' data-preset='2'>Bluer</a>
    #       <a title='Back to main interface' href='' data-preset='finished'>Return</a>
    #     </div>
    #     <div class='flag'>?</div>
    #     <div class='instructions'>Scroll to zoom.  Drag to move around the image.</div>
    #     <div class='download'>
    #       Download Data:
    #       <a href='#{@source}#{@prefix}_i.fits.fz'>i</a>
    #       <a href='#{@source}#{@prefix}_J.fits.fz'>J</a>
    #       <a href='#{@source}#{@prefix}_Ks.fits.fz'>Ks</a>
    #     </div>
    #   </div>
    #   """
    # )

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

    # VICS82: Adjust preset if provenance of IR data is CFHT:
    # if @provenances['Ks'] is 'C'
    #   preset = parseInt(preset,10) + 3

    # Pass preset to classifier so it can be stored on annotation
    @classifier.preset = preset

    # Get a preset and apply to color composite
    parameters = @parameters[preset]
    # console.log "preset, @parameters = ",preset,@parameters

    # CFHTLS:
    # @wfits.setCalibrations(1, 1, 1)
    @wfits.setCalibrations(@calibrations['g'],@calibrations['r'],@calibrations['i'])

    # VICS82: not sure this is the best way to pass down the calibrations array but it works:
    # @wfits.setCalibrations(@calibrations['Ks'],@calibrations['J'],@calibrations['i'])

    @wfits.setScales.apply(@wfits, parameters.scales)
    @wfits.setAlpha(parameters.alpha)
    @wfits.setQ(parameters.Q)

    # CFHTLS:
    @wfits.drawColor('g', 'r', 'i')

    # VICS82:
    # @wfits.drawColor('Ks', 'J', 'i')

  teardown: =>
    @wfits?.teardown()
    @wfits = undefined
    @prefix = null
    @el.find('.viewer-tools').remove()

  clearCache: ->
    for key, value of @cache
      delete @cache[key]


module.exports = QuickDashboard
