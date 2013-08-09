#handle messages passed through connected ports
define [], () ->
  (message) ->
    #require module based off requested controller
    require [message.controller], (controller) ->
      #ensure controller exists
      if controller?
        #run controller and action and pass through args
        controller(message.action, message.arguments)
