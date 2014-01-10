Page  = require 'controllers/page'
Api = require 'zooniverse/lib/api'

FILMING = true

FROM_BEFORE_BBC = 
  user_count: -23711 # this is arbitrary, but i promise the resulting number is close
  classification_count: 10027682

class HomePage extends Page
  el: $('.home')
  className: 'home'
  template: require 'views/home'
  
  elements:
    '.participants': 'participants'
    '.images': 'images'

  constructor: ->
    super
    @html @template

    Api.current.get '/projects/spacewarp', (project) =>
      if FILMING
        @participants.html @formatNumber project.user_count - FROM_BEFORE_BBC.user_count
        @images.html @formatNumber project.classification_count - FROM_BEFORE_BBC.classification_count
      else
        @participants.html @formatNumber project.user_count
        @images.html @formatNumber project.classification_count

    setInterval @cycleNames, 5000

  formatNumber: (n) ->
    n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

  cycleNames:->
    $(".observers").each ->
      to_activate = $(@).find(".showme").next(".chunk")
      if to_activate.length==0
        to_activate = $(@).find(".chunk")[0] 
      $(@).find(".chunk").removeClass("showme")
      $(to_activate).addClass("showme")

module.exports = HomePage
