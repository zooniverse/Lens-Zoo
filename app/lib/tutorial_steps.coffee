{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Welcome to SpaceWarps!'
    content: 'Gravitiational Lenses are <em>very</em> rare astronomical objects. We need your help to search the entire Canada-France-Hawaii Telescope Legacy Survey in order to discover new lenses. This short tutorial will show you how to identify gravitational lenses.'
    attachment:
      to: '.primary'
      x: 0.5
      y: 0.8
    block: '.primary, .controls:nth(0)'
  
  new Step
    header: 'What are gravitational lenses?'
    content: 'Gravitational lenses are massive astronomical objects &ndash; such as galaxies &ndash; that lie in front of more distant galaxies. Light rays from the background galaxy traveling towards our telescope are bent by the gravity of the foreground galaxy. Just as the Earth\'s gravity keeps everyday objects (including us!) on the ground, the gravitational pull of massive galaxies also attracts light: they act like huge natural magnifying glasses, focusing the light of the background galaxy towards us.'
    attachment:
      to: '.primary'
    block: '.primary, .controls:nth(0)'
  
  new Step
    header: 'Spotter\'s Guide'
    content: 'Gravitational lenses can look different depending on the positions of the foreground and background objects. Checkout the Spotter\'s Guide to see different types of lenses.'
    attachment:
      to: '.primary'
      x: 1.05
      y: 0.7
    block: '.primary, .controls:nth(0)'
    className: 'arrow-left'
  
  new Step
    header: 'Identifying gravitational lenses'
    content: 'This lens looks like a single arc near a massive galaxy. In this image the gravitational lens is a small group of massive, luminous, yellow-ish galaxies. Far behind this group is a faint blue galaxy that you see as a blue arc surrounding the group. Lensed galaxies are often (but not always!) blue, and always stretched and curved around the lens like this.'
    attachment:
      to: '.primary'
      at:
        x: 0.67
        y: 0.4
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
    content: "You don't need to identify the type of lens, we only need you to mark it. Click the brightest part of the blue arc to mark this feature as having been lensed."
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
    content: "Great, you've helped identify a gravitational lens! As you continue to search for gravitational lenses you can use the Spotter's Guide as reference.  Over your first few classifications we'll give you a few more tips and access to some different tools to help you as you search for these rare objects.  We'll also throw in a few training images containing simulated gravitational lenses, giving you a chance to test your skills.
      
      <p>Click 'Finished marking!' to continue.</p>"
    attachment:
      to: 'svg'
      at:
        x: 0.5
        y: 0.5
    block: '.controls:nth(0) a:not(".last")'
    nextOn:
      'click': 'a[data-type="finish"]'
]