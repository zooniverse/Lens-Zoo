{ Tutorial, Step }  = require 'zootorial'
translate = require 't7e'

module.exports =

  createSimulationFoundFeedback: (e, trainingType, x, y) ->

    FeedbackStrings  = translate.strings.feedback

    headers = []
    details = []

    headers.push key for key of FeedbackStrings.headers
    details.push key for key of FeedbackStrings.details[trainingType]

    # Get random header and detail
    index1 = Math.floor(Math.random() * headers.length)
    index2 = Math.floor(Math.random() * details.length) + 1

    base_header = translate 'span', "feedback.base_header"
    header = translate 'span', "feedback.headers.#{ headers[index1] }"
    detail = translate 'span', "feedback.details.#{ trainingType }.option_#{ index2 }"

    return new Tutorial
      id: 'simFound'
      firstStep: 'simFound'
      parent: @el[0]
      steps:
        length: 1

        simFound: new Step
          header: "#{ header } #{ base_header }"
          details: detail
          attachment: "left center .annotation #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'


  createSimulationMissedFeedback: (e, trainingType, x, y) ->

    FeedbackStrings  = translate.strings.feedback
    
    # Get random detail
    details = []
    details.push key for key, value of FeedbackStrings.details['missed']
    index = Math.floor(Math.random() * details.length) + 1

    return new Tutorial
      id: 'simMissed'
      firstStep: 'simMissed'
      parent: @el[0]
      steps:
        length: 1

        simMissed: new Step
          number: 1
          details: translate 'span', "feedback.details.missed.option_#{ index }"
          attachment: "left center .annotation #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'


  createDudFoundFeedback: (e) ->
    return new Tutorial
      id: 'emptyFound'
      firstStep: 'emptyFound'
      parent: @el[0]
      steps:
        length: 1

        emptyFound: new Step
          header: translate 'span', 'feedback.dud_found.header'
          details: translate 'span', 'feedback.dud_found.details'
          attachment: 'center center .annotation center center'
          block: '.annotation'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'


  createDudMissedFeedback: (e) ->
    return new Tutorial
      id: 'empty-missed'
      firstStep: 'missed'
      parent: @el[0]
      steps:
        length: 1

        missed: new Step
          header: translate 'span', 'feedback.dud_missed.header'
          details: translate 'span', 'feedback.dud_missed.details'
          attachment: 'center center .annotation center center'
          block: '.annotation'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'


  createFalsePositiveFoundFeedback: (e, trainingType, x, y) ->

    # Get failure header
    header = translate 'span', 'feedback.false_positives.failure'

    # Get details
    detail = translate 'span', "feedback.false_positives.CFHTLS_stage2_fps.#{ trainingType }"

    return new Tutorial
      id: 'fpFound'
      firstStep: 'fpFound'
      parent: @el[0]
      steps:
        length: 1

        fpFound: new Step
          number: 1
          header: header
          details: detail
          attachment: "left center .annotation #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'


  createFalsePositiveMissedFeedback: (e, trainingType, x, y) ->

    # Get success header
    header = translate 'span', 'feedback.false_positives.success'

    # Get details
    detail = translate 'span', "feedback.false_positives.CFHTLS_stage2_fps.#{ trainingType }"

    return new Tutorial
      id: 'fpMissed'
      firstStep: 'fpMissed'
      parent: @el[0]
      steps:
        length: 1

        fpMissed: new Step
          number: 1
          header: header
          details: detail
          attachment: "left center .annotation #{x} #{y}"
          block: '.annotation'
          className: 'arrow-left'
          nextButton: 'Close'
          next: true
          onExit: =>
            @viewer?.trigger 'close'

