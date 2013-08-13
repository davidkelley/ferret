define ->

  #define a port object for the active connection
  port = null

  #bind listener
  chrome?.runtime?.onConnectExternal.addListener (connection) ->
    #bind the active connection
    port = connection

    require ['handler'], (handler) ->
      #ensure the handler module deals with messages
      #passed through the connected port
      port.onMessage.addListener handler

  return {
    #send a message to the connected extension
    send: (object) ->
      if @connected?
        post.postMessage object

    #determine if there is an active connection
    connected: ->
      return port?
  }
