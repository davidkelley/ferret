#this module will contain all print actions that can be executed upon the
#device. Actions are split inside the actions submodule. ie. actions/epson

define ['device', 'buffer'], (Device, Buffer) ->
  
  #get an active printer handle
  device = new Device 'printers'

  #define a buffer for this device
  buffer = new Buffer ['prefix', 'body', 'suffix']

  #bind this buffer object to the device
  device.bind buffer

  return (type, action, args) ->
    
    #determine success to start with
    success = true

    switch type
      when "action"
        #load the set of actions for this device
        require ["actions/#{device.device.actions}"], (actions) ->

          #find the object and function
          obj = null
          fn = null

          #use dot accessor for arbitrary-depth nested actions
          action = action.split '.'

          #find a nested function ie.
          #print.this.but.align.it.left()
          for accessor in action
            if typeof obj[accessor] is "function"
              fn = obj[accessor]
              break
            else
              obj = obj[accessor]

          if fn?
            #get the returned buffer frames from the action
            parts = fn.apply actions, (args || [])

            #check to see if it succeeded
            if parts and parts.length is buffer.frames.length
              for key, frame in buffer.frames
                #push the frame into the corresponding buffer frame
                buffer[frame].push parts[key]
            else
              success = false
              #TODO: Exception handling
              #throw { message: "Buffer frames mismatch" }
          else
            success = false
            #TODO: Exception handling
            #throw { message: "No function found for action #{action}" }

      #device-based operation has been sent
      when "operation" then success = device[action]?.apply args

      #buffer-based operation has been sent
      when "buffer" then success = buffer[action]?.apply args

    #send a success callback in the same form
    require ['connector'], (connector) ->
      connector.send {
        controller: 'print',
        type: type,
        action: action,
        success: success
      }
    
