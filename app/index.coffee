require 'lib/setup'
translate = require 't7e'

{Stack} = require 'spine/lib/manager'
Route   = require 'spine/lib/route'

HomePage = require 'controllers/home_page'
AboutPage = require 'controllers/about_page'
GuidePage = require 'controllers/guide_page'
Classifier = require 'controllers/classifier'
Profile = require 'controllers/profile'
FAQPage = require 'controllers/faq_page'

Counter = require 'models/counter'

Api = require 'zooniverse/lib/api'
Analytics = require 'zooniverse/lib/google-analytics'
LanguageManager = require 'zooniverse/lib/language-manager'
TopBar = require 'zooniverse/controllers/top-bar'
User = require 'zooniverse/models/user'
Recent = require 'zooniverse/models/recent'

api = new Api
  project: 'spacewarp'

# Initialize Counter model
new Counter({classified: 0, potentials: 0, favorites: 0}).save()
  
# Navigation
$('body').append require 'views/navigation'

# Setup the stack
stack = new Stack
  el: $('.main')
  
  controllers:
    home: HomePage
    classify: Classifier
    about: AboutPage
    guide: GuidePage
    profile: Profile
    faq: FAQPage
  
  routes:
    '/home'       : 'home'
    '/classify'   : 'classify'
    '/about'      : 'about'
    '/guide'      : 'guide'
    '/profile'    : 'profile'
    '/faq'        : 'faq'
  
  default: 'home'

stack.el.appendTo 'body'

languageManager = new LanguageManager
languageManager.on 'language-fetched', (e, languageStrings) ->
  translate.load languageStrings
  translate.refresh()

topBar = new TopBar
topBar.el.appendTo 'body'

User.fetch()
Route.setup()

# Pass host to Classifier instance
stack.controllers.classify.host = api.proxyFrame.host

# Lazy loading of Guide images
$('img.lazy').lazyload({threshold : 200, effect: 'fadeIn'})

module.exports = {stack, api, topBar}
