Controller = require 'zooniverse/controllers/base-controller'
StackOfPages = require 'stack-of-pages'

class ProjectResults extends Controller
  className: 'project-results'
  template: require 'views/project-results'

  project: null

  elements:
    '.project-stack': 'projectStack'

  constructor: ->
    super

    stackHash = {}
    stackHash["#/projects/#{ @project }/summary"] = require("views/results/#{ @project }/summary")()
    stackHash["#/projects/#{ @project }/discoveries"] = require("views/results/#{ @project }/discoveries")()
    stackHash["#/projects/#{ @project }/contributors"] = require("views/results/#{ @project }/contributors")()

    stack = new StackOfPages stackHash
    @projectStack.append stack.el

module.exports = ProjectResults
