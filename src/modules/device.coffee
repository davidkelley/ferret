#find and return an active device of the requested type (ie. printer)
#use this module to also perform status checking and fault recovery...

define ['usb', 'devices'], (usb, devices) ->

  class Device

    #keep the device manifest information
    @_device

    #store google device handle object
    @_handle

    #determines if the device has been claimed
    @_claimed

    #reference the buffer object for this device
    @_buffer

    #enqueue asynchronous functions so that they can be
    #accessed and enqueued externally as synchronous functions
    @_queue: [],

    #find the active device of type and setup handle
    @constructor: (type, frames) ->
      #store context
      that = @

      #find matching devices
      devices[type] (supported) ->

        for device in supported
          (->
            #store device in context
            stored = device

            #find any active devices
            usb.findDevices stored.device, (found) ->
              #any devices found?
              if found? and found.length > 0
                #reset the device
                that.reset found[0] ->
                  #claim the device
                  that.claim found[0], stored.port, ->
                    #store handle and information
                    that._claimed = true
                    that._device = stored
                    that._handle = found[0]
              else
                throw "No active devices found"
          )()

      #return self
      return @

    #reset the device, given the device handle
    @reset: (device, callback) ->
      that = @
      usb.resetDevice device, ->
        callback() if ! that.error

    #claim the given interface on the device
    @claim: (device, port, callback) ->
      that = @
      usb.claimInterface device, port, ->
        callback() if ! that.error

    @release: (device, port, callback) ->
      that = @
      usb.releaseInterface device, port, ->
        that._claimed = false
        callback() if ! that.error

    @close: (device) ->
      that = @
      usb.closeDevice device, ->
        @_handle = null
        @_device = null
        callback() if ! that.error

    #bind a Buffer object to this device
    @bind: (buffer) ->
      #TODO: instanceof type checking
      @_buffer = buffer

    #determine if this device object has an active handle
    @ready: ->
      #TODO

    #send the contents of the bound buffer to the device
    @send: (callback) ->
      if @buffer?
        #define the data object
        data =
          direction: "out",
          endpoint: @device.endpoint,
          data: @buffer

        #transfer!
        usb.bulkTransfer @handle, data, (e) ->
          callback(e.resultCode) if typeof callback is "function"

    #wrapper for chrome device error messages
    @error: ->
      return chrome.runtime.lastError.message

  #return the device object
  Device.prototype.__defineGetter__ 'device', ->
    @_device

  #return the active device handle
  Device.prototype.__defineGetter__ 'handle', ->
    @_handle

  #return the device claimed state
  Device.prototype.__defineGetter__ 'claimed', ->
    return if @device and @handle and @_claimed then true else false

  #return the buffer object
  Device.prototype.__defineGetter__ 'buffer', ->
    #return the underlying ArrayBuffer representation of the Buffer object
    @_buffer.ArrayBuffer Uint8Array

  return Device