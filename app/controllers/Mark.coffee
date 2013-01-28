
{Controller} = require 'spine'


class Mark extends Controller
  svgns: 'http://www.w3.org/2000/svg'
  color: "#E05502"
  overColor: "#FF4500"
  selectColor: "#FF8C00"
  
  radius: 10
  p1: 6
  p2: 14
  
  constructor: ->
    super
    
    # Create SVG elements
    @gCross  = @initCross()
    @gRemove = @initRemove()
    
    # Create the root SVG group
    @gRoot = document.createElementNS(@svgns, "g")
    @gRoot.setAttribute("transform", "translate(#{@x}, #{@y})")
    
    # Append elements to root group
    @gRoot.appendChild(@gCross)
    @gRoot.appendChild(@gRemove)
    
    # Append SVG to DOM
    @el[0].appendChild(@gRoot)
    
    # Set control parameters
    @drag = false
    @hasDragged = false
    @isRemoveVisible = false
    
    # Bind mouse events
    @el.bind('mousemove', @onmousemoveEl)
    @el.bind('mouseenter', @onmouseenterEl)
    
    @gRoot.onmousedown  = @onmousedown
    @gRoot.onmouseup    = @onmouseup
    @gRoot.onclick      = @onclick
    @gRemove.onclick    = @remove
  
  initCross: =>
    
    # Create the crosshair SVG group
    gCross = document.createElementNS(@svgns, "g")
    gCross.setAttribute("stroke", @color)
    gCross.setAttribute("stroke-width", 2)
    gCross.setAttribute("fill-opacity", 0)
    gCross.setAttribute("cursor", "move")
    
    # Create an SVG circle
    c = document.createElementNS(@svgns, "circle")
    c.setAttribute("r", @radius)
    
    # Create the crosshair
    l1 = document.createElementNS(@svgns, "line")
    l2 = document.createElementNS(@svgns, "line")
    l3 = document.createElementNS(@svgns, "line")
    l4 = document.createElementNS(@svgns, "line")
    
    l1.setAttribute("x1", @p1)
    l1.setAttribute("y1", 0)
    l1.setAttribute("x2", @p2)
    l1.setAttribute("y2", 0)
    
    l2.setAttribute("x1", -@p1)
    l2.setAttribute("y1", 0)
    l2.setAttribute("x2", -@p2)
    l2.setAttribute("y2", 0)
    
    l3.setAttribute("x1", 0)
    l3.setAttribute("y1", @p1)
    l3.setAttribute("x2", 0)
    l3.setAttribute("y2", @p2)
    
    l4.setAttribute("x1", 0)
    l4.setAttribute("y1", -@p1)
    l4.setAttribute("x2", 0)
    l4.setAttribute("y2", -@p2)
    
    # Append elements to crosshair group
    gCross.appendChild(c)
    gCross.appendChild(l1)
    gCross.appendChild(l2)
    gCross.appendChild(l3)
    gCross.appendChild(l4)
    
    return gCross
  
  initRemove: =>
    
    # Create the remove SVG group
    gRemove = document.createElementNS(@svgns, "g")
    gRemove.setAttribute("transform", "translate(-#{@p2}, -#{@p2})")
    gRemove.setAttribute("cursor", "pointer")
    gRemove.setAttribute("visibility", "hidden")
    
    # Create an SVG circle
    cRemove = document.createElementNS(@svgns, "circle")
    cRemove.setAttribute("r", @p1)
    cRemove.setAttribute("fill", "#FAFAFA")
    
    # Create an SVG text element
    tRemove = document.createElementNS(@svgns, "text")
    tRemove.textContent = "x"
    tRemove.setAttribute("font-size", 11)
    tRemove.setAttribute("font-weight", 700)
    tRemove.setAttribute("x", -@p1 / 2)
    tRemove.setAttribute("y", @p1 / 2)
    
    # Append elements to remove group
    gRemove.appendChild(cRemove)
    gRemove.appendChild(tRemove)
    
    return gRemove
  
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
    @gRoot.setAttribute("transform", "translate(#{@x}, #{@y})")
  
  onmouseenterEl: (e) =>
    e.preventDefault()
    if @drag
      @onmouseup(e)
  
  onmousedown: (e) =>
    e.preventDefault()
    
    @drag = true
    @gCross.setAttribute("stroke", @overColor)
  
  onmouseup: (e) =>
    e.preventDefault()
    @drag = false
    @gCross.setAttribute("stroke", @color)
  
  onclick: (e) =>
    e.preventDefault()
      
    if @isRemoveVisible
      @gRemove.setAttribute("visibility", "hidden")
      @gCross.setAttribute("stroke", @color)
    else
      @gRemove.removeAttribute("visibility")
      @gCross.setAttribute("stroke", @selectColor)
    @isRemoveVisible = not @isRemoveVisible
    
    if @hasDragged
      @gRemove.setAttribute("visibility", "hidden")
      @gCross.setAttribute("stroke", @color)
      @hasDragged = false
      @isRemoveVisible = false
  
  toJSON: =>
    annotation =
      x: @x
      y: @y
    return annotation
  
  remove: =>
    @gRoot.remove()
    @trigger 'remove', @


module.exports = Mark