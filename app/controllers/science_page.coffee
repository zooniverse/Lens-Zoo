Page  = require 'controllers/page'


class SciencePage extends Page
  el: $('.science')
  className: 'science'
  
  constructor: ->
    super
    
module.exports = SciencePage