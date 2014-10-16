StackOfPages = require 'stack-of-pages'

Page = require 'controllers/page'
ProjectResults = require 'controllers/project-results'

class Results extends Page
  el: $('.results')
  className: 'results'
  template: require 'views/results'

  projects: require 'lib/project-surveys'

  events:
    'click .page-menu li': 'show'
  
  constructor: ->
    super
    @html @template @

    stackHash = 'default': "#/projects/#{ @projects[0] }/summary"
    for project in @projects
      stackHash["#/projects/#{ project }/*"] = (class extends ProjectResults then project: project)

    resultsStack = new StackOfPages stackHash
    document.querySelector('#results-stack').appendChild resultsStack.el

  show: ({ currentTarget }) =>
    $(currentTarget).addClass('show').siblings('li').removeClass('show')

module.exports = Results
