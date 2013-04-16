Page  = require 'controllers/page'


class GuidePage extends Page
  el: $('.guide')
  className: 'guide'
  
  events:
    'click .menu li'  : 'show'
  
  active: ->
    super
    @el.scroll()  # trick lazyload
  
  show: (e) =>
    target = e.currentTarget
    $(target).addClass('show').siblings('li').removeClass('show')
    $('section[data-type="' + target.dataset.type + '"]').addClass('show').siblings('section').removeClass('show')

    @el.scroll() # trick lazyload


module.exports = GuidePage