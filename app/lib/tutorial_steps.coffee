{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Welcome to SpaceWarps!'
    content: 'This short tutorial will show you how to identify gravitational lenses.'
    attachment:
      to: '.current'
  
  new Step
    header: 'What are gravitational lenses?'
    content: 'Gravitational lenses are observed when two massive astronomical objects &ndash; such as galaxies &ndash; are in the same line of sight of our telescope.  Light from the background galaxy traveling towards the telescope is bent by the gravity of the foreground galaxy.  Just as gravity attracts our day-to-day objects, it also attracts light.  When this phenomenom occurs, the gravity of the foreground galaxy has acted like a natural magnifying lense on the bent light of the background galaxy.'
    attachment:
      to: '.current'
  
  new Step
    header: 'Canada-France-Hawaii Telescope Legacy Survey'
    content: 'Lenses are <em>very</em> rare astronomical objects.  We need your help to search the entire Canada-France-Hawaii Telescope Legacy Survey.'
    attachment:
      to: '.current'
  
  new Step
    header: 'Identifying gravitational lenses'
    content: 'In this image the gravitational lense is evident by the blue arc surrounding the more luminous yellow-ish objects.<br/><br/>The luminous yellow-ish objects have bent the light of the blue background galaxy.<br/><br/>Click in the center of the blue arc to mark the lense.'
    attachment:
      to: '.current'
      at:
        x: 0.9
        y: 0.45
    nextOn:
      'click': '.current .image svg'
  
  new Step
    header: 'Identifying gravitational lenses.'
    content: "Great, you've helped identify a lense!  Since lenses are rare and often difficult to spot, we've developed a few more tools to help discover them."
    attachment:
      to: '.current'
      at:
        x: 0.9
        y: 0.45
  
  new Step
    header: 'Dashboard'
    content: "Dashboard is a place to examine your data even further.  You will find tools to visualize these data with more control, and help us build a catalog of some of the rarest objects in the universe."
    attachment:
      to: '.current'
      at:
        x: 0.5
        y: 0.65

  new Step
    header: 'Talk'
    content: "Talk is a place to discuss these images with the rest of the SpaceWarps community.  If you have questions, the Science Team and others will help answer them.  Please contribute if you find something interesting."
    attachment:
      to: '.current'
      at:
        x: 0.5
        y: 0.65
  
  new Step
    content: "That's about all.  More information can be found on the <em>Science</em> page.  Thanks for helping out in this rare object search!"
    attachment:
      to: '.current'
]