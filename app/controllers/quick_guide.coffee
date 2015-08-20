{ Controller } = require 'spine'

class QuickGuide extends Controller
  className: 'quick-guide'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # RECONFIGURATION:
  # Which survey are we supporting with this Quick Spotter's Guide?
  # Note that the images to use (and the title text to pop up) are
  # specified in translations/en_US.coffee!
  template: require 'views/quick_guide/quick_guideCFHTLSstage2' # This was unchanged from CFHTLS Stage 1.
  # template: require 'views/quick_guide/quick_guideVICS82'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  show: false

  events:
    'click .tab': 'toggle'
    'click img': 'onClick'

  constructor: ->
    super
    @html @template

  toggle: =>
    right = if @show then 0 else -1 * @el.width()
    @el.css('right', right)
    @show = not @show

  onClick: (e) =>
    type = e.target.dataset.type
    @navigate('/guide')

    if type in ['lensing-clusters', 'lensed-galaxies', 'lensed-quasars']
      sectionType = 'real-lenses'
    if type in ['noise', 'offsets']
      sectionType = 'artifacts'
    else
      sectionType = 'false-positives'

    $(".guide-menu li[data-type='#{sectionType}']").click()
    $("ul.menu li[data-type='#{type}']").click()

module.exports = QuickGuide
