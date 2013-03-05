Page  = require 'controllers/page'


class GuidePage extends Page
  el: $('.guide')
  className: 'guide'
  
  events:
    'click li' : 'onSection'
  
  
  onSection: (e) =>
    @el.find('li').removeClass('show')
    $(e.currentTarget).addClass('show')
    type = e.currentTarget.dataset.type
    $("section").removeClass('show')
    $("section[data-type='#{type}']").addClass('show')
    
    # Trigger scroll to trick jQuery LazyLoad
    @el.scroll()

module.exports = GuidePage