_     = require 'underscore/underscore'
Page  = require 'controllers/page'


class Classifier extends Page
  className: 'classifier'
  template: require 'views/classifier'
  subjectTemplate: require 'views/subject'
  nSubjectCache: 5
  waitToRemove: 1000
  nSubjects: 0
  
  # TEMP CODE:
  ids: [1..30]
  
  elements:
    '[data-type="classified"]'    : 'nClassified'
    '[data-type="potentials"]'    : 'nPotentials'
    '[data-type="favorites"]'     : 'nFavorites'
    '.subjects'                   : 'subjects'
  
  events:
    'click div:nth(0)[data-type="heart"]'     : 'onFavorite'
    'click div:nth(0)[data-type="discuss"]'   : 'onDiscuss'
    'click div:nth(0)[data-type="dashboard"]' : 'onDashboard'
    'click div:nth(0)[data-type="finish"]'    : 'onFinish'
    'click .current img'                      : 'onMark'
  
  
  constructor: ->
    super
    
    @html @template
    
    # Get stats from API
    @setClassified(123)
    @setPotentials(321)
    @setFavorites(987)
    
    @initSubjects()
  
  setClassified: (n) =>
    @nClassified.text(n)
  
  setPotentials: (n) =>
    @nPotentials.text(n)
  
  setFavorites: (n) =>
    @nFavorites.text(n)
  
  # Select five random subjects
  initSubjects: =>
    # Check that there are enough subjects
    if @ids.length < 1
      alert 'Out of subjects'
      return null
    
    @getSubject() for i in [1..5]
    @el.find('.subject').first().addClass('current')
  
  getSubject: =>
    
    # Get random number from array
    n = _.random(0, @ids.length - 1)
    id = String('0' + @ids[n]).slice(-2)
    @ids = _.without(@ids, @ids[n])
    url = "data/CFHTLS_#{id}.png"
    params =
      url: url
    @subjects.append @subjectTemplate(params)
  
  onMark: (e) =>
    console.log e
    
    # TEMP: Not really gonna do it this way.
    x = e.offsetX
    y = e.offsetY
    img = document.createElement('img')
    img.src = 'images/marker.png'
    img.onload = ->
      img.style.position = 'relative'
      img.style.top = "#{y - 12}px"
      img.style.left = "#{x - 12}px"
      document.querySelector('.current').appendChild(img)
    
  
  onFavorite: (e) =>
    console.log 'onFavorite'
  
  onDiscuss: (e) =>
    console.log 'onDiscuss'
  
  onDashboard: (e) =>
    console.log 'onDashboard'
  
  onFinish: (e) =>
    target = $(e.currentTarget)
    subject = target.parent().parent()
    sibling = subject.siblings().first()
    
    subject.addClass('to-remove')
    subject.removeClass('current')
    
    sibling.addClass('current')
    sibling.removeClass('right')
    
    setTimeout ->
      subject.remove()
    , @waitToRemove
    
    if @ids.length > 1
      @getSubject()


module.exports = Classifier