{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Training image'
    content: "Yes, that was a simulated lens! Well spotted!"
    attachment:
      to: 'svg'
      at:
        x: 0.9
        y: 0.6
]