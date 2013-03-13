Page  = require 'controllers/page'


class GuidePage extends Page
  el: $('.guide')
  className: 'guide'
  
  events:
    'click li.tab'  : 'onArticle'
    # 'click li'      : 'onSection'
  
  elements:
    '.tab'  : 'tabs'
  
  active: ->
    super
    @el.scroll()  # trick lazyload
  
  onArticle: (e) =>
    @tabs.removeClass('show')
    $(e.currentTarget).addClass('show')
  
  onSection: (e) =>
    @el.find('li').removeClass('show')
    $(e.currentTarget).addClass('show')
    type = e.currentTarget.dataset.type
    $("section").removeClass('show')
    $("section[data-type='#{type}']").addClass('show')
    
    @el.scroll()  # trick lazyload

module.exports = GuidePage