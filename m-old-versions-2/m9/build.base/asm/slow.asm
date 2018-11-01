;
;		automatically generated
;
; ******** con.clear.screen ********
define_slow_63_6f_6e_2e_63_6c_65_61_72_2e_73_63_72_65_65_6e:
  jp   IOClearScreen

; ---------------------------------------------

; ******** con.ink ********
define_slow_63_6f_6e_2e_69_6e_6b:
  ld   a,(IOAttribute)
  and  $F8
  ld   b,a
  ld   a,l
  and  $07
  or    b
  or   $40
  ld   (IOAttribute),a
  ret

; ---------------------------------------------

; ******** con.inkey ********
define_slow_63_6f_6e_2e_69_6e_6b_65_79:
  ex   de,hl
  call  IOScanKeyboard
  ld   l,a
  ld   h,0
  ret

; ---------------------------------------------

; ******** con.paper ********
define_slow_63_6f_6e_2e_70_61_70_65_72:
  ld   a,(IOAttribute)
  and  $C7
  ld   b,a
  ld   a,l
  and  $07
  add  a,a
  add  a,a
  add  a,a
  or   b
  ld   (IOAttribute),a
  ret

; ---------------------------------------------

; ******** con.cursor! ********
define_slow_63_6f_6e_2e_63_75_72_73_6f_72_21:
  jp   IOSetCursor

; ---------------------------------------------

; ******** con.screen! ********
define_slow_63_6f_6e_2e_73_63_72_65_65_6e_21:
  ld   a,e
  jp   IOWriteCharacter

; ---------------------------------------------

; ******** - ********
define_macro_2d:
  db end_define_macro_2d-define_macro_2d-1
  ld   b,h
  ld   c,l
  ld  h,d
  ld   l,e
  xor   a
  sbc  hl,bc
end_define_macro_2d:

; ---------------------------------------------

; ******** + ********
define_macro_2b:
  db end_define_macro_2b-define_macro_2b-1
  add   hl,de
end_define_macro_2b:

; ---------------------------------------------

; ******** * ********
define_macro_2a:
  db end_define_macro_2a-define_macro_2a-1
  call Multiply16
end_define_macro_2a:

; ---------------------------------------------

; ******** c@ ********
define_macro_63_40:
  db end_define_macro_63_40-define_macro_63_40-1
  ld   l,(hl)
  ld   h,0
end_define_macro_63_40:

; ---------------------------------------------

; ******** c! ********
define_macro_63_21:
  db end_define_macro_63_21-define_macro_63_21-1
  ld   (hl),e
end_define_macro_63_21:

; ---------------------------------------------

; ******** @ ********
define_macro_40:
  db end_define_macro_40-define_macro_40-1
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
end_define_macro_40:

; ---------------------------------------------

; ******** ! ********
define_macro_21:
  db end_define_macro_21-define_macro_21-1
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
end_define_macro_21:

; ---------------------------------------------

; ******** false ********
define_macro_66_61_6c_73_65:
  db end_define_macro_66_61_6c_73_65-define_macro_66_61_6c_73_65-1
  ex   de,hl
  ld   hl,$0000
end_define_macro_66_61_6c_73_65:

; ---------------------------------------------

; ******** pop.ab ********
define_macro_70_6f_70_2e_61_62:
  db end_define_macro_70_6f_70_2e_61_62-define_macro_70_6f_70_2e_61_62-1
  pop  hl
  pop  de
end_define_macro_70_6f_70_2e_61_62:

; ---------------------------------------------

; ******** pop.bb ********
define_macro_70_6f_70_2e_62_62:
  db end_define_macro_70_6f_70_2e_62_62-define_macro_70_6f_70_2e_62_62-1
  pop  de
  pop  de
end_define_macro_70_6f_70_2e_62_62:

; ---------------------------------------------

; ******** push.ab ********
define_macro_70_75_73_68_2e_61_62:
  db end_define_macro_70_75_73_68_2e_61_62-define_macro_70_75_73_68_2e_61_62-1
   push  de
   push  hl
end_define_macro_70_75_73_68_2e_61_62:

; ---------------------------------------------

; ******** a>r ********
define_macro_61_3e_72:
  db end_define_macro_61_3e_72-define_macro_61_3e_72-1
  push  hl
end_define_macro_61_3e_72:

; ---------------------------------------------

; ******** ; ********
define_macro_3b:
  db end_define_macro_3b-define_macro_3b-1
  ret
end_define_macro_3b:

; ---------------------------------------------

; ******** r>a ********
define_macro_72_3e_61:
  db end_define_macro_72_3e_61-define_macro_72_3e_61-1
  ex   de,hl
  pop  hl
end_define_macro_72_3e_61:

; ---------------------------------------------

; ******** true ********
define_macro_74_72_75_65:
  db end_define_macro_74_72_75_65-define_macro_74_72_75_65-1
  ex   de,hl
  ld   hl,$FFFF
end_define_macro_74_72_75_65:

; ---------------------------------------------

; ******** a>b ********
define_macro_61_3e_62:
  db end_define_macro_61_3e_62-define_macro_61_3e_62-1
  ld   d,h
  ld   e,l
end_define_macro_61_3e_62:

; ---------------------------------------------

; ******** b>a ********
define_macro_62_3e_61:
  db end_define_macro_62_3e_61-define_macro_62_3e_61-1
  ld   h,d
  ld   l,e
end_define_macro_62_3e_61:

; ---------------------------------------------

; ******** swap ********
define_macro_73_77_61_70:
  db end_define_macro_73_77_61_70-define_macro_73_77_61_70-1
  ex   de,hl
end_define_macro_73_77_61_70:

; ---------------------------------------------

; ******** 1- ********
define_macro_31_2d:
  db end_define_macro_31_2d-define_macro_31_2d-1
  dec  hl
end_define_macro_31_2d:

; ---------------------------------------------

; ******** 1+ ********
define_macro_31_2b:
  db end_define_macro_31_2b-define_macro_31_2b-1
  inc  hl
end_define_macro_31_2b:

; ---------------------------------------------

; ******** 2/ ********
define_macro_32_2f:
  db end_define_macro_32_2f-define_macro_32_2f-1
  sra  h
  rr   l
end_define_macro_32_2f:

; ---------------------------------------------

; ******** 2- ********
define_macro_32_2d:
  db end_define_macro_32_2d-define_macro_32_2d-1
  dec  hl
  dec  hl
end_define_macro_32_2d:

; ---------------------------------------------

; ******** 2+ ********
define_macro_32_2b:
  db end_define_macro_32_2b-define_macro_32_2b-1
  inc  hl
  inc  hl
end_define_macro_32_2b:

; ---------------------------------------------

; ******** 2* ********
define_macro_32_2a:
  db end_define_macro_32_2a-define_macro_32_2a-1
  add  hl,hl
end_define_macro_32_2a:

; ---------------------------------------------

; ******** bswap ********
define_macro_62_73_77_61_70:
  db end_define_macro_62_73_77_61_70-define_macro_62_73_77_61_70-1
  ld   a,h
  ld   h,l
  ld   l,a
end_define_macro_62_73_77_61_70:

; ---------------------------------------------

; ******** breakpoint ********
define_macro_62_72_65_61_6b_70_6f_69_6e_74:
  db end_define_macro_62_72_65_61_6b_70_6f_69_6e_74-define_macro_62_72_65_61_6b_70_6f_69_6e_74-1
  db   $DD,$01
end_define_macro_62_72_65_61_6b_70_6f_69_6e_74:

; ---------------------------------------------

; ******** debug ********
define_slow_64_65_62_75_67:
  push  de
  push  hl
  push  de
  ex   de,hl
  ld   hl,23+23*32
  call  IODisplayHexInteger
  pop  de
  ld   hl,28+23*32
  call  IODisplayHexInteger
  pop  hl
  pop  de
  ret

; ---------------------------------------------

; ******** halt ********
define_macro_68_61_6c_74:
  db end_define_macro_68_61_6c_74-define_macro_68_61_6c_74-1
HaltProcessor:
  halt
  jr   HaltProcessor
end_define_macro_68_61_6c_74:

; ---------------------------------------------

; ******** system.info ********
define_variable_73_79_73_74_65_6d_2e_69_6e_66_6f:
SISystemInformation:
SINextFreeSlow:
 dw   HighSlowMemory
SINextFreeFast:
 dw   HighFastMemory
SINextFreeFastPage:
 db   0,0
SIRunTimeAddress:
 dw   HaltProcessor
SIStack:
 dw   Z80Stack

; ---------------------------------------------

