{Controller} = require 'spine'


class Page extends Controller
    
    activate: =>
      super
      $("[data-page='#{@className}']").addClass('active')

    deactivate: =>
      super
      $("[data-page='#{@className}']").removeClass('active')
    
module.exports = Page