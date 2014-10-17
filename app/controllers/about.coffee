Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages'

class About extends Controller
  className: 'about'
  template: require 'views/about'
  
  events:
    'click .menu li': 'show'
    'click .guide-menu li': 'show'
  
  constructor: ->
    super
    @el.on StackOfPages::activateEvent, @activate
  
  activate: =>
    @el.scroll()  # trick lazyload
  
  show: (e) =>
    target = e.currentTarget
    type = $(target).data('type')
    
    $(target).addClass('show').siblings('li').removeClass('show')
    $("section[data-type='#{type}']").addClass('show').siblings('section').removeClass('show')

    @el.scroll() # trick lazyload

module.exports = About
