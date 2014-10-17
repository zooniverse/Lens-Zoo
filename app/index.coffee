require 'lib/setup'
translate = require 't7e'
StackOfPages = require 'stack-of-pages'

Counter = require 'models/counter'

Api = require 'zooniverse/lib/api'
Analytics = require 'zooniverse/lib/google-analytics'
LanguageManager = require 'zooniverse/lib/language-manager'
activeHashLinks = require 'zooniverse/util/active-hash-links'
TopBar = require 'zooniverse/controllers/top-bar'
User = require 'zooniverse/models/user'
Recent = require 'zooniverse/models/recent'

api = new Api project: 'spacewarp'

# Initialize Counter model
new Counter({classified: 0, potentials: 0, favorites: 0}).save()

enUs = require 'translations/en_us'
esCl = require 'translations/es_cl'
translate.load enUs

languageManager = new LanguageManager
  translations:
    en: label: 'English', strings: enUs
    es: label: 'Español', strings: esCl

languageManager.on 'change-language', (e, code, strings) ->
  translate.load strings
  translate.refresh()

topBar = new TopBar
topBar.el.appendTo 'body'

# Navigation
$('body').append require 'views/navigation'

stack = new StackOfPages
  '#/home': require 'controllers/home'
  '#/classify': require 'controllers/classifier'
  '#/about': require 'controllers/about'
  '#/guide': require 'controllers/guide'
  '#/profile': require 'controllers/profile'
  '#/faq': require 'controllers/faq'
  '#/projects/*': require 'controllers/results'
  default: '#/'
document.body.appendChild stack.el

new Analytics
  account: 'UA-1224199-43'
  domain: 'spacewarps.org'

User.fetch()

# Lazy loading of Guide images
$('img.lazy').lazyload({threshold : 200, effect: 'fadeIn'})

module.exports = {stack, api, topBar}
