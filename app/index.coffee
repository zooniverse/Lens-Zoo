require('lib/setup')

$       = require 'jqueryify'
{Stack} = require 'spine/lib/manager'
Route   = require 'spine/lib/route'

HomePage    = require 'controllers/home_page'
SciencePage = require 'controllers/science_page'
Classifier  = require 'controllers/classifier'
Dashboard   = require 'controllers/dashboard'
Profile     = require 'controllers/profile'

Api     = require 'zooniverse/lib/api'
TopBar  = require 'zooniverse/controllers/top-bar'
User    = require 'zooniverse/models/user'

# Setup the stack
stack = new Stack
  el: $('.main')
  
  controllers:
    home: HomePage
    classify: Classifier
    science: SciencePage
    dashboard: Dashboard
    profile: Profile
  
  routes:
    '/home'       : 'home'
    '/classify'   : 'classify'
    '/science'    : 'science'
    '/dashboard'  : 'dashboard'
    '/profile'    : 'profile'
  
  default: 'home'
  
# Configure connection to Api
api = new Api
  project: 'spacewarp'
  host: "http://localhost:3000"
  path: '/proxy'


# Load the top bar last since it fetches the user.
topBar = new TopBar

# User.fetch()

stack.el.appendTo 'body'
topBar.el.appendTo 'body'

Route.setup()


module.exports = {stack, api, topBar}