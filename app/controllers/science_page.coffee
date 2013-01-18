Page  = require 'controllers/page'


class SciencePage extends Page
  className: 'science'
  template: require 'views/science_page'
  
  constructor: ->
    super
    @html @template
    
module.exports = SciencePage