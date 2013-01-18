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
TopBar  = require 'zooniverse/lib/controllers/top_bar'
User    = require 'zooniverse/lib/models/user'

googleAnalytics = require 'zooniverse/lib/google_analytics'
BrowserCheck    = require 'zooniverse/lib/controllers/browser_check'

bc = new BrowserCheck
bc.support.opera = 12
bc.check()


# googleAnalytics.init
#   account: 'UA-XXXXXXX-XX'
#   domain: 'spacewarps.org'


# TODO: Setup proxy to dev/api

app = {}

$('.before-load').remove()
app.stack = new Stack
  className: "main #{Stack::className}"
  
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
  
# # Load the top bar last since it fetches the user.
# app.topBar = new TopBar
#   app: 'spacewarps'
#   appName: 'SpaceWarps'
# 
# $(window).on 'request-login-dialog', ->
#   app.topBar.onClickSignUp()
#   app.topBar.loginForm.signInButton.click()
#   app.topBar.loginDialog.reattach()

app.stack.el.appendTo 'body'
# app.topBar.el.prependTo 'body'

Route.setup()


module.exports = app
    