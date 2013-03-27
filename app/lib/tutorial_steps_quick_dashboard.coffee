# {Tutorial}  = require 'zootorial'
# {Step}      = Tutorial
# 
# 
# module.exports = [
#   new Step
#     header: 'Quick Dashboard'
#     content: "Welcome to the Quick Dashboard!  Use this space to visualise raw astronomical data to uncover rare gravitational lenses."
#     attachment:
#       to: 'svg'
#       at:
#         x: 0.5
#         y: 0.5
#     block: '.mask, .primary, .controls'
# 
#   new Step
#     header: 'Unveiling lenses'
#     content: "Three presets are provided to help discover lenses with low surface brightness.<br/><br/>Experiment by clicking through them."
#     attachment:
#       to: 'svg'
#       at:
#         x: -0.4
#         y: 1.07
#     block: '.mask, .primary'
#     className: 'arrow-right narrow'
#     onEnter: ->
#       $('.viewer').css('z-index', 6)
#       $('.primary').css('z-index', 7)
#       $('.viewer .controls a:last').on('click', null, (e) ->
#         e.preventDefault()
#         e.stopPropagation()
#       )
#       $('.viewer .controls a:last').css('cursor', 'not-allowed')
#     onExit: ->
#       $('.viewer .controls a:last').css('cursor', 'pointer')
#       $('.viewer .controls a:last').off('click', null)
# 
#   new Step
#     header: 'Zooming and Panning'
#     content: "Get a closer look on your lense candidates by zooming and panning through the image.
#     <ul>
#       <li>Zoom using the mouse wheel</li>
#       <li>Pan by holding the space bar and dragging</li>
#     </ul>"
#     attachment:
#       to: 'svg'
#       at:
#         x: -0.4
#         y: 0.5
#     block: '.mask'
#     className: 'narrow'
# 
#   new Step
#     header: 'Returning to classifying'
#     content: "Return back to the classification page by clicking outside the image or pressing the escape key."
#     attachment:
#       to: 'svg'
#       at:
#         x: 0.5
#         y: 0.5
#     block: '.mask, .controls'
#     defaultButton: 'Done'
# 
# ]