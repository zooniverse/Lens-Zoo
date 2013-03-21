{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Training image'
    content: "Yes, that was a simulated lens! Well spotted!"
    attachment:
      to: 'svg'
      at:
        x: 0.9
        y: 0.57
    className: 'arrow-left'
    onEnter: ->
      bounding = document.createElementNS('http://www.w3.org/2000/svg', "circle")
      bounding.setAttribute("transform", "translate(#{172}, #{258})")
      bounding.setAttribute("stroke", 'white')
      bounding.setAttribute("stroke-width", 2)
      bounding.setAttribute("r", 40)
      bounding.setAttribute("fill-opacity", 0)
      bounding.setAttribute("opacity", 0.4)
      $("svg.primary")[0].appendChild(bounding)
]