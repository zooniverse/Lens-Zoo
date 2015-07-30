Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages/stack-of-pages'

class About extends Controller
  className: 'about'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # RECONFIGURATION:
  # Which survey are we introducing?
  # template: require 'views/about/aboutCFHTLSstage1'
  # template: require 'views/about/aboutCFHTLSstage2'
  # template: require 'views/about/aboutVICS82'
  template: require 'views/about/aboutCFHTLSreboot'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
