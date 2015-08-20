Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages/stack-of-pages'
Configuration = require '../lib/configuration'

class Guide extends Controller
  className: 'guide'
  template: Configuration.GuideTemplate

  events:
    'click .menu li': 'show'
    'click .guide-menu li': 'show'

  constructor: ->
    super
    @el.on StackOfPages::activateEvent, @activate

  activate: =>
    @el.scroll() # trick lazyload

  show: (e) =>
    target = e.currentTarget
    type = $(target).data('type')

    $(target).addClass('show').siblings('li').removeClass('show')
    $("section[data-type='#{type}']").addClass('show').siblings('section').removeClass('show')

    @el.scroll() # trick lazyload

module.exports = Guide
