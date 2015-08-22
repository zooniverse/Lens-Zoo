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
    stackHash["#/projects/#{ @project }/summary"] = require("views/results/#{ @project }/summary")({ @project })
    stackHash["#/projects/#{ @project }/discoveries"] = require("views/results/#{ @project }/discoveries")({ @project })
    stackHash["#/projects/#{ @project }/contributors"] = require("views/results/contributors")({ @project })

    stack = new StackOfPages stackHash
    @projectStack.append stack.el

    window.addEventListener 'hashchange', @onHashChange
    @onHashChange()

  onHashChange: =>
    currentHash = if location.hash[location.hash.length - 1] == '/'
      location.hash.slice 0, location.hash.length - 1
    else
      location.hash

    if (currentHash.indexOf(@project) > -1) and (currentHash.indexOf(@project) == currentHash.length - @project.length)
      location.hash = currentHash + '/summary'

    @menuItems.removeClass('show').find("a[href='#{ location.hash }']").parent().addClass('show')

module.exports = ProjectResults
