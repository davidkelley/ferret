#this module contains all print actions relative to the EPSON TM printers
define ['operators'], (ops) ->
  return {
    #add characters to print on the line
    write: (chars) ->
      unless Array.isArray chars
        chars = (""+chars).split('')

      if chars.length > 0
        char = char.charCodeAt(0) for char in chars
      else
        return false

      return [[], chars, []]

    #write a line of characters
    writeLn: (chars) ->
      arr = @write chars
      arr[1].push ops.LF
      return arr

    #setup alignments
    align: (->
      alignments = {left: 0, center: 1, right: 2}

      #sort through alignments and build functions
      for key, alignment in alignments
        (->
          num = alignment
          alignment = ->
            return [[ops.ESC, 0x61, num], [], []]
        )()

      return alignments
    )(),

    #configure text magnification
    magnify: (n) ->
      if 0 <= n <= 15
        str = Number(n).toString(2)
        str = "0" + str while str.length < 4
        return [[ops.GS, 0x21, parseInt(str+str, 2)], [], []]
      else
        return false

    #split text on the left and right side of the paper
    split: (left, right) ->
      #create empty buffer pattern
      arr = [[], [], []]

      #set alignment and reset magnification
      arr[0] = [].concat @align.left()[0], @magnify(0)[0]

      #set spaces inbetween the words
      spaces = ""
      spaces += " " while spaces.length < (40 - left.length - right.length)

      #set character array
      arr[1] = [].concat @writeLn(left + spaces + right)[1]

      #return constructed buffer pattern
      return arr

    #n = true or false
    embolden: (n) ->
      return [[ops.ESC, 0x45, +n], [], []]

    #n = true or false
    smoothing: (n) ->
      return [[ops.GS, 0x62, +n], [], []]

    #n = 0|false: off, 1|true: 1-dot width, 2: 2-dot width
    underline: (n) ->
      return [[ops.ESC, 0x2D, +n], [], []]

    #n = true or false
    upsideDown: (n) ->
      return [[OPS.GS, 0x7B, +n], [], []]

    #print and feed the paper n lines
    print: (n) ->
      return [[], [], [ops.ESC, 0x64, n]]

    #cut the paper
    cut: ->
      return [[], [], [ops.GS, 0x56, 1]]

    #parse an image to send to the buffer using canvas getImageData
    #requirements:
    #options.width must be less than X
    #options.height must be divisable by 24
    #options.threshold must be set
    #options.data must contain result of getImageData(...).data
    image: (options) ->
      #set vertical slice
      verticalSlice = 24

      #create the buffer frames
      data = []
      #set line spacing to 24 in the prefix, back to default in the suffix
      buffer = [[ops.ESC, 0x61, 1, ops.ESC, 0x33, 24], data, [ops.ESC, 0x32]]

      #loop over splices of images 24 pixels high. ie. image of 96 has 4 splices
      for rows in [0...options.height] by 24

        #determine width of image. n + (l * 256) = width
        n = options.width % 256
        l = Math.floor options.width / 256

        #push "print this image" command to printer
        data.push ops.ESC, 0x2A, 33, n, l

        #create a monochromatic representation of the rgb data
        monochrome = (
          #loop through the RGBA data passed through
          for i in [0...options.data.length] by 4
            #get the rgba values
            r = options.data[i]
            g = options.data[i + 1]
            b = options.data[i + 2]
            a = options.data[i + 3]

            #no, calculate its luminance
            luminance = parseInt r * 0.3 + g * 0.59 + b * 0.11

            #draw this bit (not if its transparent)
            if a isnt 255 and luminance < options.threshold then 1 else 0
        )

        #loop through monochromatic array and build buffered bytes
        for x in [0...options.width] by 1
          #3 bytes in each column.. (24 / 3)
          for k in [0...3] by 1
            #create an empty slice of bits...
            slice = (
              #build the byte, 8 bits
              for b in [0...8] by 1
                #find location of this "pixel" and cash it as string "0" or "1"
                monochrome[(k * 8 + b) * options.width + x]
            )
            #push and parse byte
            data.push parseInt(slice.join(''), 2)

        #advance the printer by a newline
        data.push 0x0A

      #return the buffer object
      return buffer

    #send a status command
    #n = 1, printer status
    #n = 2, offline cause status
    #n = 3, error cause status
    #n = 4, paper end status
    status: (n) ->
      return [[ops.DLE, ops.EOT, n], [], []]

  }