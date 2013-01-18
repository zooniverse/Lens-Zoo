{Controller} = require 'spine'


class Profile extends Controller
  className: 'profile'
  template: require 'views/profile'
    
  constructor: ->
    super
    
    @html @template
    
module.exports = Profile