Page  = require 'controllers/page'


class Dashboard extends Page
  el: $('.dashboard')
  className: 'dashboard'
    
  constructor: ->
    super
    
    
module.exports = Dashboard