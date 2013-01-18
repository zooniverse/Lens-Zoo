Page  = require 'controllers/page'


class Profile extends Page
  className: 'profile'
  template: require 'views/profile'
    
  constructor: ->
    super
    
    @html @template
    
module.exports = Profile