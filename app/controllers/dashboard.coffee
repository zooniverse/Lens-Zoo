{Controller} = require 'spine'


class Dashboard extends Controller
  className: 'dashboard'
  template: require 'views/dashboard'
  
  constructor: ->
    super
    
    @html @template
    
    
module.exports = Dashboard