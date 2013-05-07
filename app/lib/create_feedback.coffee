
{Tutorial}  = require 'zootorial'
{Step}      = require 'zootorial'

Feedback  = require 'lib/feedback'


module.exports =
  
  createSimulationFoundFeedback: (e, trainingType, x, y) ->
    
    # Get random header and detail
    if trainingType in ['lensing cluster', 'lensed quasar', 'lensed galaxy']
      
      header = Feedback.header
      detail = Feedback.detail[trainingType]
      
      index1 = Math.floor(Math.random() * header.length)
      index2 = Math.floor(Math.random() * detail.length)
      
      header = Feedback.header[index1] + '!'
      detail = detail[index2]
    
    return new Tutorial
      id: 'simFound'
      firstStep: 'simFound'
      parent: @el[0]
      steps:
        length: 1
        
        simFound: new Step
          header: header
          details: detail
          attachment: "left center .primary #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Next image'
          next: true
          onExit: =>
            @submit(e)
            @viewer?.trigger 'close'
  
  createSimulationMissedFeedback: (e, trainingType, x, y) ->
    return new Tutorial
      id: 'simMissed'
      firstStep: 'simMissed'
      parent: @el[0]
      steps:
        length: 1
        
        simMissed: new Step
          number: 1
          header: 'Whoops!'
          details: "You missed a simulated #{trainingType}!  Don't worry, let's move to the next image."
          attachment: "left center .primary #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Next image'
          next: true
          onExit: =>
            @submit(e)
            @viewer?.trigger 'close'
  
  createDudFoundFeedback: (e) ->
    return new Tutorial
      id: 'emptyFound'
      firstStep: 'emptyFound'
      parent: @el[0]
      steps:
        length: 1
        
        emptyFound: new Step
          header: 'Nice! There is no gravitational lens in this field!'
          details: "This is a different kind of Training Image, one that has already been inspected by the Science Team and found not to contain any gravitational lenses."
          attachment: 'center center .primary center center'
          block: '.annotation'
          nextButton: 'Next image'
          next: true
          onExit: =>
            @submit(e)
            @viewer?.trigger 'close'
  
  createDudMissedFeedback: (e) ->
    return new Tutorial
      id: 'empty-missed'
      firstStep: 'missed'
      parent: @el[0]
      steps:
        length: 1
        
        missed: new Step
          header: 'There is no gravitational lens in this field!'
          details: "This is a different kind of Training Image, one that has already been inspected by the Science Team and found not to contain any gravitational lenses."
          attachment: 'center center .primary center center'
          block: '.annotation'
          nextButton: 'Next image'
          next: true
          onExit: =>
            @submit(e)
            @viewer?.trigger 'close'
