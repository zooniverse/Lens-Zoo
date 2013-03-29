{Controller} = require 'spine'


class QuickGuide extends Controller
  className: 'quick-guide'
  template: require 'views/quick_guide'
  show: true
  
  events:
    'click .tab'  : 'toggle'

  constructor: ->
    super
    @html @template
  
  toggle: =>
    right = if @show then -1 * @el.width() else 0
    @el.css('right', right)
    @show = not @show
    
module.exports = QuickGuide