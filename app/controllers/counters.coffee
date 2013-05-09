
{Controller} = require 'spine'

Counter = require 'models/counter'


class Counters extends Controller
  template: require 'views/counters'
  
  
  constructor: ->
    super
    Counter.bind("update", @render)
  
  render: =>
    @html @template(Counter.first())
    
  removeSimulationFrequency: ->
    @el.find('.stat').last().remove()


module.exports = Counters