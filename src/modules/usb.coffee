define [], ->
  #wrap usb interface
  if chrome?.usb? then return chrome.usb else return false