{Tutorial}  = require 'zootorial'
{Step}      = Tutorial


module.exports = [
  new Step
    header: 'Talk'
    content: "Talk is a place to discuss these images with the rest of the SpaceWarps community: together we aim to build a catalog of some of the rarest objects in the universe. If you have questions, the Science Team and other astronomers will help answer them. If you find something that looks interesting, come and show it to the group!"
    attachment:
      to: 'svg'
      at:
        x: 0.5
        y: 0.5
    block: '.primary, .controls'
]