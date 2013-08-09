define [], ->

  #declare a frame. A frame is a part of the buffer
  class Frame

    #store the data for this frame
    @data: [];

    #convert any strings passed into the frame
    @arrayify (arr) ->
      return if Array.isArray(arr) then arr else [arr]

    #set data to the buffer
    #note, this completely resets the buffer
    @set: ->
      @data = [].concat.apply [], arguments

    #prefix data to the start of this frame
    @prefix: (arr) ->
      @set @arrayify(arr), @data

    #append data to the end of the frame
    @suffix: (arr) ->
      @set @data, @arrayify(arr)

    #wrapper method for suffixing
    @push: ->
      @suffix.apply @, arguments

    #empty the frame
    @empty: ->
      @data = []

  #create a buffer base class for storing byte based information
  #a buffer can have different parts
  class Buffer

    #define parts of the buffer
    @frames

    #setup the buffer 
    constructor: (frames) ->
      unless frames?
        #no parts, simply return a singular frame
        return new Frame

      #set frames
      @frames = frames

      #define a new frame for each part of the requested buffer
      @[frame] = new Frame for frame in frames when frame isnt ""

      return @

    #get a singular array of all frames
    get: ->
      arr = []
      arr.concat(@[frame]) for frame in @frames
      return arr

    #clear the buffer
    clear: ->
      @frame.empty for frame in @frames

    #build the underlying ArrayBuffer object
    ArrayBuffer: (type) ->
      return new type(@get).buffer

  #define a getter for frame length
  Frame.prototype.__defineGetter__ 'length', ->
    @data.length

  #define a getter for buffer length
  Buffer.prototype.__defineGetter__ 'length', ->
    n = 0
    n += frame.length for frame in @frames
    return n

  #return the Buffer class
  return Buffer