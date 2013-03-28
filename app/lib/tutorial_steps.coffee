{Tutorial}  = require 'zootorial'
{Step}      = require 'zootorial'

module.exports =
  length: 8
  
  welcome: new Step
    number: 1
    header: 'Welcome to Space Warps!'
    details: 'Gravitational Lenses are very rare astronomical objects. We need your help finding them. This short tutorial will show you how to identify gravitational lenses.'
    attachment: 'center center .primary center center'
    block: '.primary, .controls'
    next: 'what_are_lenses_1'
  
  what_are_lenses_1: new Step
    number: 2
    header: 'What are gravitational lenses?'
    details: 'Gravitational lenses are massive astronomical objects &ndash; such as galaxies &ndash; that lie in front of other, more distant galaxies. These massive objects act like huge natural magnifying glasses by focusing the light from distant objects towards us allowing us to see further into our universe.'
    attachment: 'center center .primary center center'
    block: '.primary, .controls'
    next: 'what_are_lenses_2'
  
  what_are_lenses_2: new Step
    number: 3
    header: 'What are gravitational lenses?'
    details: 'Gravitational lenses can look different, depending on how they line up along the line-of-sight to us, and on the shape and type of the foreground lens and background objects.'
    attachment: 'center center .primary center center'
    block: '.primary, .controls'
    next: 'spotters_guide'
  
  spotters_guide: new Step
    number: 4
    header: "Spotter's Guide"
    details: "Check out The Spotter's Guide  for detailed descriptions and reference images of Real Lenses and False Positives.  You can use the Spotter's Guide as a reference throughout your time on Space Warps."
    attachment: 'left center [data-page="guide"] right center'
    block: '.primary, .controls'
    className: 'arrow-left'
    next: 'identify'
  
  identify: new Step
    number: 5
    header: 'Identifying gravitational lenses'
    details: "This small group of yellow-ish galaxies is a gravitational lens. It is bending and magnifying the light from a faint blue galaxy lying far behind it into a blue arc, that surrounds the group."
    attachment: 'left top .primary right 0.18'
    block: '.primary, .controls'
    className: 'arrow-left'
    onEnter: ->
      bounding = document.createElementNS('http://www.w3.org/2000/svg', "circle")
      bounding.setAttribute("transform", "translate(#{175}, #{172})")
      bounding.setAttribute("class", "outline")
      bounding.setAttribute("stroke", 'white')
      bounding.setAttribute("stroke-width", 2)
      bounding.setAttribute("r", 50)
      bounding.setAttribute("fill-opacity", 0)
      bounding.setAttribute("opacity", 0.4)
      $("svg.primary")[0].appendChild(bounding)
    next: 'mark'
  
  mark: new Step
    number: 6
    header: 'Marking lensed features'
    details: 'If you see something that is being lensed, please mark it by clicking the blue arc.'
    attachment: 'left top .primary right 0.18'
    block: '.controls'
    className: 'arrow-left'
    onEnter: (tutorial) ->
      canvas = document.createElement('canvas')
      @ctx = canvas.getContext('2d')
      img = new Image()
      img.onload = (e) =>
        canvas.width = img.width
        canvas.height = img.height
        @ctx.drawImage(img, 0, 0, img.width, img.height)
      img.src = $('.current .image img').attr('src')
    next:
      'mouseup svg.primary': (e, tutorial, step) ->
        position = $('.current .image').position()
        x = e.pageX - position.left
        y = e.pageY - position.top
        
        pixel = step.ctx.getImageData(x, y, 1, 1)
        mask = pixel.data[3]
        return if mask is 255 then 'training' else false
  
  training: new Step
    number: 7
    header: 'Training images'
    details: "From time to time we'll throw in a training image like this one, that contains a simulated or previously known gravitational lens. When you mark those lenses you'll see a similar message, to let you know that you are on the right track."
    attachment: 'left top .primary right 0.18'
    block: '.primary, .controls'
    next: 'thanks'
  
  thanks: new Step
    number: 8
    header: 'Thanks!'
    details: "Remember lensed galaxies are rare: many of the images you will see won't contain a gravitational lens. You can keep track of the expected lens frequency as you go at the top of this page.<br/><br/>Over your first few classifications we'll give you a few more tips and access to some different tools to help you as you search for these rare objects.<br/><br/>Click 'Finished marking!' to continue."
    attachment: 'center center .primary center center'
    block: '.primary, .current .controls a:not(:last)'
    next:
      'click .controls a.last': true
  