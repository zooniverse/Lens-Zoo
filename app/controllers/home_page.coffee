{Controller} = require 'spine'


class HomePage extends Controller
  el: $('.home')
  className: 'home'
  
  constructor: ->
    super
    
module.exports = HomePage