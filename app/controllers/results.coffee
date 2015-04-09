Page  = require 'controllers/page'
StackOfPages = require 'stack-of-pages/stack-of-pages'

class Results extends Page
  el: $('.results')
  className: 'results'
  template: require 'views/results'

  events:
    'click .page-menu li': 'show'

  constructor: ->
    super
    @html @template

    resultsStack = new StackOfPages
      '#/results': require('views/results/initial-results')()
      '#/results/contributors': require('views/results/contributors')()
    document.querySelector('#results-stack').appendChild resultsStack.el

  show: ({ currentTarget }) =>
    $(currentTarget).addClass('show').siblings('li').removeClass('show')


module.exports = Results
