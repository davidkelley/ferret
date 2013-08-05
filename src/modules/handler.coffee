#handle messages passed through connected ports
define [], () ->
  (message) ->
    require [message.controller], (controller) ->
      if controller? and message.action in controller
        controller[message.action].apply controller, message.arguments
