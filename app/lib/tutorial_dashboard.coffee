{Tutorial}  = require 'zootorial'
{Step}      = require 'zootorial'

module.exports =
  length: 1
  
  dashboard: new Step
    number: 1
    header: 'Quick Dashboard'
    details: 'As gravitationally lensed features can be faint and/or small, you can explore an image in more detail in the Quick Dashboard. Try clicking on this button.'
    attachment: 'center bottom [data-type="dashboard"] 0.55 -0.2'
    className: 'arrow-bottom'
    onEnter: ->
      $('.current .controls a[data-type="dashboard"]').addClass('hover')
    onExit: ->
      $('.current .controls a[data-type="dashboard"]').removeClass('hover')
    next:
      'click a': true