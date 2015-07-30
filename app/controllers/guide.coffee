Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages/stack-of-pages'

class Guide extends Controller
  className: 'guide'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # RECONFIGURATION:
  # Which survey are we supporting with this Spotter's Guide?
  # template: require 'views/guide/guideCFHTLSstage1' - NOT TESTED, DO NOT USE. IT HAS BEEN SUPERCEDED BY THE STAGE 2 GUIDE.
  template: require 'views/guide/guideCFHTLSstage2'
  # template: require 'views/guide/guideVICS82'
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
