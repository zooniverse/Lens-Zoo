
TutorialCallbacks =
  
  onTutorialStart: (e) =>
    console.log 'onTutorialStart', arguments
  
  onTutorialStep: (e, n, step) =>
    console.log 'onTutorialStep', arguments
  
  onTutorialComplete: =>
    console.log 'onTutorialComplete', arguments
  
  onTutorialEnd: (e) =>
    console.log 'onTutorialEnd', arguments
  
module.exports = TutorialCallbacks