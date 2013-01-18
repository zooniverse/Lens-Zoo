{Controller} = require 'spine'
_ = require 'underscore/underscore'

class Classifier extends Controller
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  nSubjectCache: 5
  
  # TEMP CODE:
  ids: [1..30]
  
  elements:
    '[data-type="classified"]'    : 'nClassified'
    '[data-type="potentials"]'    : 'nPotentials'
    '[data-type="favorites"]'     : 'nFavorites'
    '.subjects'                   : 'subjects'
  
  events:
    'click [data-type="finish"]'  : 'submit'
  
  constructor: ->
    super
    
    @html @template
    
    # Get stats from API
    @setClassified(123)
    @setPotentials(321)
    @setFavorites(987)
    
    @getSubjects()
  
  setClassified: (n) =>
    @nClassified.text(n)
  
  setPotentials: (n) =>
    @nPotentials.text(n)
  
  setFavorites: (n) =>
    @nFavorites.text(n)
  
  # Select five random subjects
  getSubjects: =>
    
    for i in [0..@nSubjectCache - 1]
      
      # Check that there are enough subjects
      if @ids.length < 1
        alert 'Out of subjects'
        return null
      
      # Choose random number, select from array of subject ids, pluck subject from array
      n = _.random(0, @ids.length)
      id = String('0' + @ids[n]).slice(-2)
      @ids = _.without(@ids, @ids[n])
      url = "data/CFHTLS_#{id}.png"
      @subjects.append @subjectTemplate({index: i, url: url})
  
  submit: (e) =>
    current = $(e.currentTarget)
    subject = current.parent().parent()
    subject.addClass('to-remove')
    
    setTimeout ->
      subject.remove()
    , 750


module.exports = Classifier