Page  = require 'controllers/page'


class HomePage extends Page
  el: $('.home')
  className: 'home'
  
  constructor: ->
    super
    
module.exports = HomePage