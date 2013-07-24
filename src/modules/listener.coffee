define ->
	#bind listener
	chrome?.runtime?.onConnectExternal.addListener (port) ->
		require ['handler'], (handler) ->
			#ensure the handler module deals with messages
			#passed through the connected port
			port.onMessage.addListener handler
