{ Controller } = require 'spine'
Configuration = require '../lib/configuration'

class QuickGuide extends Controller
  className: 'quick-guide'
  template: Configuration.QuickGuideTemplate

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
    window.location.hash = '/guide'

    type = e.target.dataset.type

    if type in ['lensing-clusters', 'lensed-galaxies', 'lensed-quasars']
      sectionType = 'real-lenses'
    else if type in ['noise', 'offsets']
      sectionType = 'artifacts'
    else
      sectionType = 'false-positives'

    $(".guide-menu li[data-type='#{sectionType}']").click()
    $("ul.menu li[data-type='#{type}']").click()

module.exports = QuickGuide
