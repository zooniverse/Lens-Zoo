{Controller} = require 'spine'


class QuickGuide extends Controller
  className: 'quick-guide'
  template: require 'views/quick_guide'
  show: false
  
  events:
    'click .tab'  : 'toggle'

  constructor: ->
    super
    @html @template
    
  toggle: =>
    right = if @show then 0 else -1 * @el.width()
    @el.css('right', right)
    @show = not @show
    
module.exports = QuickGuide