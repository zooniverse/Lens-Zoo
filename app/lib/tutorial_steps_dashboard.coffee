{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Quick Dashboard'
    content: "Welcome to the Quick Dashboard!  Use this space to visualise raw astronomical data to uncover rare gravitational lenses."
    attachment:
      to: 'svg'
      at:
        x: 0.5
        y: 0.5
    block: '.mask, .primary, .controls'

  new Step
    header: 'Presets to discover lenses'
    content: "Three presets are provided that change the colour of the image.  These presets are commonly used among astronomers to unveil the subtle, low surface brightness features such as gravitational lenses.
    <p>Experiment by clicking through them.</p>"
    attachment:
      to: 'svg'
      at:
        x: 1.5
        y: 0.9
    block: '.mask, .primary'
    onEnter: ->
      $('.viewer').css('z-index', 6)
      $('.primary').css('z-index', 7)
      $('.viewer .controls a:last').click( (e) ->
        e.preventDefault()
        e.stopPropagation()
      )
      $('.viewer .controls a:last').css('cursor', 'not-allowed')

  new Step
    header: 'Zooming and Panning'
    content: "Get a closer look on your lense candidates by zooming and panning through the image.
    <ul>
      <li>Zoom using the mouse wheel</li>
      <li>Pan by holding the space bar and dragging</li>
    </ul>"
    attachment:
      to: 'svg'
      at:
        x: 1.5
        y: 0.9
    block: '.mask'

  new Step
    header: 'Returning to classifying'
    content: "Return back to the classification page by clicking outside the image or pressing the escape key."
    attachment:
      to: 'svg'
      at:
        x: 0.5
        y: 0.5
    block: '.mask, .controls'
    defaultButton: 'Done'

]