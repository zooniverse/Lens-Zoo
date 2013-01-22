{Controller} = require 'spine'

class Mark extends Controller
  color: "#E05502"
  overColor: "#FF8C00"
  radius: 10
  
  constructor: ->
    super
    
    # Create an SVG element
    c = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    c.setAttribute("cx", @x)
    c.setAttribute("cy", @y)
    c.setAttribute("r", @radius)
    c.setAttribute("stroke", @color)
    c.setAttribute("stroke-width", 2)
    c.setAttribute("fill-opacity", 0)
    @el[0].appendChild(c)
    @circle = c
    
    # Bind mouse events
    @drag = false
    @el.bind('mousemove', @onmousemoveEl)
    @el.bind('mouseenter', @onmouseenterEl)
    c.onmousedown = @onmousedown
    c.onmouseup   = @onmouseup
  
  onmousemoveEl: (e) =>
    e.preventDefault()
    return unless @drag
    
    # Update instance variables
    @x = e.offsetX
    @y = e.offsetY
    @circle.setAttribute("cx", @x)
    @circle.setAttribute("cy", @y)
  
  onmouseenterEl: (e) =>
    e.preventDefault()
    @onmouseup(e)
  
  onmousedown: (e) =>
    e.preventDefault()
    @drag = true
    @circle.setAttribute("stroke", @overColor)
  
  onmouseup: (e) =>
    e.preventDefault()
    @drag = false
    @circle.setAttribute("stroke", @color)


module.exports = Mark