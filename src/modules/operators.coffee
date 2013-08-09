define [], ->
  #object containing statically referenced byte operators
  return {
    NUL: 0x00,
    EOT: 0x04,
    ENQ: 0x05,
    HT: 0x09,
    LF: 0x0A,
    FF: 0x0C,
    CR: 0x0D,
    DLE: 0x10,
    DC4: 0x14,
    CAN: 0x18,
    ESC: 0x01B,
    FS: 0x1C,
    GS: 0x1D
  }