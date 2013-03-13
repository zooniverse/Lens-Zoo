{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Welcome to SpaceWarps!'
    content: 'Gravitiational Lenses are <em>very</em> rare astronomical objects. We need your help to search the entire Canada-France-Hawaii Telescope Legacy Survey in order to discover new lenses. This short tutorial will show you how to identify gravitational lenses.'
    attachment:
      to: 'svg'
      x: 0.5
      y: 0.8
  
  new Step
    header: 'What are gravitational lenses?'
    content: 'Gravitational lenses are massive astronomical objects &ndash; such as galaxies &ndash; that lie in front of more distant galaxies. Light rays from the background galaxy traveling towards our telescope are bent by the gravity of the foreground galaxy. Just as the Earth\'s gravity keeps everyday objects (including us!) on the ground, the gravitational pull of massive galaxies also attracts light: they act like huge natural magnifying glasses, focusing the light of the background galaxy towards us.'
    attachment:
      to: 'svg'
  
  new Step
    header: 'Spotter\'s Guide'
    content: 'Gravitational lenses can look different depending on the positions of the foreground and background objects. Checkout the Spotter\'s Guide to see different types of lenses.'
    attachment:
      to: 'svg'
      x: 0.5
      y: 0.8
  
  new Step
    header: 'Identifying gravitational lenses'
    content: 'This lens looks like a single arc near a massive galaxy. In this image the gravitational lens is a small group of massive, luminous, yellow-ish galaxies. Far behind this group is a faint blue galaxy that you see as a blue arc surrounding the group. Lensed galaxies are often (but not always!) blue, and always stretched and curved around the lens like this.'
    attachment:
      to: 'svg'
      at:
        x: 0.65
        y: 0.4
  
  new Step
    header: 'Marking gravitational lenses'
    content: "You don't need to identify the type of lens, we only need you to mark it. Click the brightest part of the blue arc to mark this feature as having been lensed."
    attachment:
      to: 'svg'
      at:
        x: 0.65
        y: 0.5
    nextOn:
      'click': 'svg.primary'
  
  new Step
    header: 'Good job!'
    content: "Great, you've helped identify a gravitational lens! As you continue to search for gravitational lenses you can use the Spotter's Guide as reference.  Over your first few classifications we'll give you a few more tips and access to some different tools to help you as you search for these rare objects.  We'll also throw in a few training images containing simulated gravitational lenses, giving you a chance to test your skills.
      
      <p>Click 'Finished marking!' to continue.</p>"
    attachment:
      to: 'svg'
      x: 0.5
      y: 0.8
    nextOn:
      'click': 'a[data-type="finish"]'
  
  new Step
    header: 'Talk'
    content: "Talk is a place to discuss these images with the rest of the SpaceWarps community: together we aim to build a catalog of some of the rarest objects in the universe. If you have questions, the Science Team and other astronomers will help answer them. If you find something that looks interesting, come and show it to the group!"
    attachment:
      to: 'svg'
      x: 0.5
      y: 0.5
  
  new Step
    header: 'Training image'
    content: 'Yes!  That was a simulated lens, well spotted!'
    attachment:
      to: 'svg'
      x: 0.5
      y: 0.5
]