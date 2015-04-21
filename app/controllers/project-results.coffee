Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages/stack-of-pages'

class ProjectResults extends Controller
  className: 'project-results'
  template: require 'views/project-results'

  project: null
  
  elements:
    '.project-results-menu li': 'menuItems'
    '.project-stack': 'projectStack'

  constructor: ->
    super

    stackHash = {}
    stackHash["#/projects/#{ @project }/summary"] = require("views/results/#{ @project }/summary")()
    stackHash["#/projects/#{ @project }/discoveries"] = require("views/results/#{ @project }/discoveries")()
    stackHash["#/projects/#{ @project }/contributors"] = require("views/results/#{ @project }/contributors")()

    stack = new StackOfPages stackHash
    @projectStack.append stack.el

    window.addEventListener 'hashchange', @onHashChange
    @onHashChange()

  onHashChange: =>
    # yuck
    @menuItems.removeClass('show').find("a[href='#{ location.hash }']").parent().addClass('show')

module.exports = ProjectResults
