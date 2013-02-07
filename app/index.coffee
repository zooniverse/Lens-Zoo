require('lib/setup')

$       = require 'jqueryify'
{Stack} = require 'spine/lib/manager'
Route   = require 'spine/lib/route'

HomePage    = require 'controllers/home_page'
SciencePage = require 'controllers/science_page'
Classifier  = require 'controllers/classifier'
Profile     = require 'controllers/profile'

Api     = require 'zooniverse/lib/api'
TopBar  = require 'zooniverse/controllers/top-bar'
User    = require 'zooniverse/models/user'
Recent  = require 'zooniverse/models/recent'

# Setup the stack
stack = new Stack
  el: $('.main')
  
  controllers:
    home: HomePage
    classify: Classifier
    science: SciencePage
    profile: Profile
  
  routes:
    '/home'       : 'home'
    '/classify'   : 'classify'
    '/science'    : 'science'
    '/profile'    : 'profile'
  
  default: 'home'
  
# Configure connection to Api
api = new Api
  project: 'spacewarp'
  host: "https://dev.zooniverse.org"
  # host: "http://0.0.0.0:3000"
  path: '/proxy'

topBar = new TopBar
User.fetch()
topBar.el.appendTo 'body'
stack.el.appendTo 'body'
Route.setup()


module.exports = {stack, api, topBar}