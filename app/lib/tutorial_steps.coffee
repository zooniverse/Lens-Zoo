{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Welcome to SpaceWarps!'
    content: 'Gravitiational Lenses are <em>very</em> rare astronomical objects. This short tutorial will show you how to identify gravitational lenses.'
    attachment:
      to: '.primary'
      x: 0.5
      y: 0.8
    block: '.primary, .controls:nth(0)'
  
  new Step
    header: 'What are gravitational lenses?'
    content: 'Gravitational lenses are massive astronomical objects &ndash; such as galaxies &ndash; that lie in front of more distant galaxies. Light rays from the background galaxy traveling towards our telescope are bent by the gravity of the foreground galaxy.'
    attachment:
      to: '.primary'
    block: '.primary, .controls:nth(0)'
  
  new Step
    header: 'Spotter\'s Guide'
    content: 'Gravitational lenses can look different depending on the positions of the foreground and background objects.<br/></br>Checkout the Spotter\'s Guide to see different types of lenses.'
    attachment:
      to: '.primary'
      x: 1.05
      y: 0.7
    block: '.primary, .controls:nth(0)'
    className: 'arrow-left'
  
  new Step
    header: 'Identifying gravitational lenses'
    content: 'This lens looks like a single arc near a massive galaxy.'
    attachment:
      to: '.primary'
      at:
        x: 0.67
        y: 0.5
    block: '.primary, .controls:nth(0)'
    className: 'arrow-bottom'
    onEnter: ->
      bounding = document.createElementNS('http://www.w3.org/2000/svg', "circle")
      bounding.setAttribute("transform", "translate(#{287}, #{357})")
      bounding.setAttribute("stroke", 'white')
      bounding.setAttribute("stroke-width", 2)
      bounding.setAttribute("r", 50)
      bounding.setAttribute("fill-opacity", 0)
      bounding.setAttribute("opacity", 0.4)
      $("svg.primary")[0].appendChild(bounding)
    onExit: ->
      $("svg.primary").empty()
  
  new Step
    header: 'Marking gravitational lenses'
    content: "Click the brightest part of the blue arc to mark this feature as having been lensed."
    className: 'arrow-bottom'
    attachment:
      to: '.primary'
      at:
        x: 0.67
        y: 0.59
    block: '.controls:nth(0)'
    nextOn:
      'click': '.primary'
  
  new Step
    header: 'Good job!'
    content: "Great, you've helped identify a gravitational lens!<br/><br/>Click 'Finished marking!' to continue."
    attachment:
      to: 'svg'
      at:
        x: 0.5
        y: 0.5
    block: '.controls:nth(0) a:not(".last")'
    nextOn:
      'click': 'a[data-type="finish"]'
]