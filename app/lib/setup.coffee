
translate = require 't7e'
if localStorage['spacewarp-languageStrings']
  languageStrings = JSON.parse localStorage['spacewarp-languageStrings']
else
  languageStrings = require 'translations/en_us'

translate.load languageStrings

require 'json2ify'
require 'es5-shimify'
require 'spine'

require 'lib/jquery.lazyload'
