{Controller} = require 'spine'

# Behaviour
# onclick shows the remove SVG
# subsequent onclick hides the remove SVG



class Mark extends Controller
  # color: "#E05502"
  # overColor: "#FF4500"
  # selectColor: "#FF8C00"
  
  color: 'red'
  overColor: 'green'
  selectColor: 'blue'
  
  radius: 10
  
  constructor: ->
    super
    svgns = 'http://www.w3.org/2000/svg'
    
    # Create an SVG group element
    g = document.createElementNS(svgns, "g")
    g.setAttribute("transform", "translate(#{@x}, #{@y})")
    
    # Create an SVG circle
    c = document.createElementNS(svgns, "circle")
    c.setAttribute("r", @radius)
    c.setAttribute("stroke", @color)
    c.setAttribute("stroke-width", 2)
    c.setAttribute("fill-opacity", 0)
    c.setAttribute("cursor", "move")
    
    # Create an SVG group element to contain remove trigger
    gRemove = document.createElementNS(svgns, "g")
    gRemove.setAttribute("transform", "translate(-14, -14)")
    gRemove.setAttribute("cursor", "pointer")
    gRemove.setAttribute("visibility", "hidden")
    
    # Create an SVG circle
    removeC = document.createElementNS(svgns, "circle")
    removeC.setAttribute("r", 6)
    removeC.setAttribute("fill", "#FAFAFA")
    
    # Create an SVG text element
    t = document.createElementNS(svgns, "text")
    t.textContent = "x"
    t.setAttribute("font-size", 11)
    t.setAttribute("font-weight", 700)
    t.setAttribute("x", -3)
    t.setAttribute("y", 3)
    
    # Append all elements
    gRemove.appendChild(removeC)
    gRemove.appendChild(t)
    
    g.appendChild(c)
    g.appendChild(gRemove)
    @el[0].appendChild(g)
    
    # Store SVG DOM elements
    @g = g
    @circle = c
    @gRemove = gRemove
    
    # Control parameters
    @drag = false
    @hasDragged = false
    @isRemoveVisible = false
    
    # Bind mouse events
    @el.bind('mousemove', @onmousemoveEl)
    @el.bind('mouseenter', @onmouseenterEl)
    g.onmousedown = @onmousedown
    g.onmouseup   = @onmouseup
    g.onclick     = @onclick
    @gRemove.onclick = @remove
  
  onmousemoveEl: (e) =>
    e.preventDefault()
    return unless @drag
    
    @hasDragged = true
    
    # Hide the remove SVG
    @gRemove.setAttribute("visibility", "hidden")
    @isRemoveVisible = false
    
    # Update instance variables
    @x = e.offsetX
    @y = e.offsetY
    @g.setAttribute("transform", "translate(#{@x}, #{@y})")
  
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
  
  onclick: (e) =>
    e.preventDefault()
      
    if @isRemoveVisible
      @gRemove.setAttribute("visibility", "hidden")
      @circle.setAttribute("stroke", @color)
    else
      @gRemove.removeAttribute("visibility")
      @circle.setAttribute("stroke", @selectColor)
    @isRemoveVisible = not @isRemoveVisible
    
    if @hasDragged
      @gRemove.setAttribute("visibility", "hidden")
      @circle.setAttribute("stroke", @color)
      @hasDragged = false
      @isRemoveVisible = false
    
  remove: =>
    @g.remove()
    @trigger 'remove', @


module.exports = Mark