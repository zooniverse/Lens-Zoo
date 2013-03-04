

class Viewer extends Spine.Controller
  template: require 'views/viewer'
  dimension: 440
  
  
  constructor: ->
    super
    
    @html @template
    @getApi()
  
  getApi: ->
    unless DataView?
      alert 'Sorry, your browser does not support features needed for this tool.'

    # Determine if WebGL is supported, otherwise fall back to canvas
    canvas  = document.createElement('canvas')
    context = canvas.getContext('webgl')
    context = canvas.getContext('experimental-webgl') unless context?

    # Load appropriate WebFITS library asynchronously
    lib = if context? then 'gl' else 'canvas'
    url = "javascripts/webfits-#{lib}.js"
    $.getScript(url, =>
      console.log 'webfits loaded'
    )
  
  load: ->
    console.log 'load'
    
    @wfits = new astro.WebFITS(@el[0], @dimension)
    console.log @wfits
  
  teardown: ->
    console.log 'teardown'
    @el.hide()
  
module.exports = Viewer