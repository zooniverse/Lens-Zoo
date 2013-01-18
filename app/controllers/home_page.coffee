{Controller} = require 'spine'


class HomePage extends Controller
  className: 'home'
  template: require 'views/home_page'
  
  constructor: ->
    super
    
    @html @template
    
module.exports = HomePage