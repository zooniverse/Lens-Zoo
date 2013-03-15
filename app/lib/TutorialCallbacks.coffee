
TutorialCallbacks =
  
  onTutorialStart: (e) =>
    console.log 'onTutorialStart', arguments, @
  
  onTutorialStep: (e, n, step) =>
    console.log 'onTutorialStep', arguments
    
    # Hide the dialog
    if n is 7
      console.log @
      @tutorialEl.hide()
  
  onTutorialComplete: =>
    console.log 'onTutorialComplete', arguments
  
  onTutorialEnd: (e) =>
    console.log 'onTutorialEnd', arguments


module.exports = TutorialCallbacks