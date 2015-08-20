Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages/stack-of-pages'

ProjectResults = require 'controllers/project-results'

class Results extends Controller
  className: 'results'
  template: require 'views/results'
  projects: require 'lib/project-surveys'

  elements:
    '.page-menu li': 'menuItems'

  events:
    'click .page-menu li': 'onClickMenu'

  constructor: ->
    super
    stackHash = {}
    for project in @projects
      stackHash["#/projects/#{ project }/*"] = (class extends ProjectResults then project: project)

    resultsStack = new StackOfPages stackHash
    @el.find('#results-stack').append resultsStack.el

    @menuItems.first().click()

  onClickMenu: ({ currentTarget }) ->
    $(currentTarget).addClass('show').siblings().removeClass('show')

module.exports = Results
