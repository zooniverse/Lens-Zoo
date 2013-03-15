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
    $(e.currentTarget).addClass('show').siblings('li').removeClass('show')

    key = $(e.currentTarget).data('type')
    $('section[data-type="'+key+'"]').addClass('show').siblings('section').removeClass('show')

    @el.scroll() # trick lazyload


module.exports = GuidePage