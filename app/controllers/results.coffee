Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages'

ProjectResults = require 'controllers/project-results'

class Results extends Controller
  className: 'results'
  template: require 'views/results'

  projects: require 'lib/project-surveys'

  events:
    'click .page-menu li': 'show'
  
  constructor: ->
    super
    stackHash = 'default': "#/projects/#{ @projects[0] }/summary"
    for project in @projects
      stackHash["#/projects/#{ project }/*"] = (class extends ProjectResults then project: project)

    resultsStack = new StackOfPages stackHash
    console.log resultsStack
    @el.find('#results-stack').append resultsStack.el

  show: ({ currentTarget }) =>
    $(currentTarget).addClass('show').siblings('li').removeClass('show')

module.exports = Results
