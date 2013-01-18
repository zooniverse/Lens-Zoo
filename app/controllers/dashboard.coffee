Page  = require 'controllers/page'


class Dashboard extends Page
  className: 'dashboard'
  template: require 'views/dashboard'
  
  constructor: ->
    super
    
    @html @template
    
    
module.exports = Dashboard