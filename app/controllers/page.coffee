{Controller} = require 'spine'


class Page extends Controller
    
    activate: =>
      super
      $("[data-page='#{@className}']").addClass('active')
      $(window).scrollTop(0)

    deactivate: =>
      super
      $("[data-page='#{@className}']").removeClass('active')
    
module.exports = Page