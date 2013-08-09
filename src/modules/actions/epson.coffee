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
        str = Number(n).toString(2);
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

  }