define [], ->

  #store all devices
  devices = null

  #queue any calls whilst we fetch devices
  queued = []

  module =
    #retrieve the first, connected printer
    #callback returns the connected printer object or null
    printers: (callback) ->
      if devices?
        #return all defined printers
        callback devices.usbDevices.printers
      else
        #devices not ready, enqueue call
        queued.push ->
          this.printers callback

  #get the file containing all devices
  $.getJSON '/devices.json', (data) ->
    devices = data
    fn.call(module) for fn in queued

  #return the module
  return module
