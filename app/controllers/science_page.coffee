{Controller} = require 'spine'


class SciencePage extends Controller
  className: 'science'
  template: require 'views/science_page'
  
  constructor: ->
    super
    @html @template
    
module.exports = SciencePage