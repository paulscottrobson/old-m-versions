;
;		automatically generated
;
; ******** system.clear ********
define_73_79_73_74_65_6d_2e_63_6c_65_61_72_word:
  jp   IOClearScreen

; ---------------------------------------------

; ******** system.inkey ********
define_73_79_73_74_65_6d_2e_69_6e_6b_65_79_word:
  call  IOScanKeyboard
  ld   l,a
  ld   h,0
  ret

; ---------------------------------------------

; ******** system.cursor! ********
define_73_79_73_74_65_6d_2e_63_75_72_73_6f_72_21_word:
  jp   IOSetCursor

; ---------------------------------------------

; ******** system.screen! ********
define_73_79_73_74_65_6d_2e_73_63_72_65_65_6e_21_word:
  ld   a,e
  jp   IOWriteCharacter

; ---------------------------------------------

; ******** and ********
define_61_6e_64_word:
  ld   a,h
  and  d
  ld   h,a
  ld   a,l
  and  e
  ld   l,a
  ret

; ---------------------------------------------

; ******** max ********
define_6d_61_78_word:
  xor  a
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a
  ret  z
  ld   h,d
  ld   l,e
  ret

; ---------------------------------------------

; ******** min ********
define_6d_69_6e_word:
  xor  a
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a
  ret  nz
  ld   h,d
  ld   l,e
  ret

; ---------------------------------------------

; ******** mod ********
define_6d_6f_64_word:
  push   de
  call   DivideMod16
  pop   de
  ret

; ---------------------------------------------

; ******** or ********
define_6f_72_word:
  ld   a,h
  or   d
  ld   h,a
  ld   a,l
  or   e
  ld   l,a
  ret

; ---------------------------------------------

; ******** / ********
define_2f_word:
  push   de
  call   DivideMod16
  ex    de,hl
  pop   de
  ret

; ---------------------------------------------

; ******** = ********
define_3d_word:
  ld   a,h
  cp   d
  jr   nz,SetFalse
  ld   a,l
  cp   e
  jr   nz,SetFalse
SetTrue:
  ld   hl,$FFFF
  ret
SetFalse:
  ld   hl,0000
  ret

; ---------------------------------------------

; ******** > ********
define_3e_word:
__Greater:
  xor  a
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a
  jr   nz,SetTrue
  jr   SetFalse
  ret

; ---------------------------------------------

; ******** >= ********
define_3e_3d_word:
  ld   a,h
  cp   d
  jr   nz,__Greater
  ld   a,l
  cp   e
  jr   nz,__Greater
  jr   SetTrue
  ret

; ---------------------------------------------

; ******** < ********
define_3c_word:
  ld   a,h
  cp   d
  jr   nz,__LessEqual
  ld   a,l
  cp   e
  jr   nz,__LessEqual
  jr   SetFalse
  ret

; ---------------------------------------------

; ******** <= ********
define_3c_3d_word:
__LessEqual:
  xor  a
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a
  jr   z,SetTrue
  jr   SetFalse
  ret

; ---------------------------------------------

; ******** <> ********
define_3c_3e_word:
  ld   a,h
  cp   d
  jr   nz,SetTrue
  ld   a,l
  cp   e
  jr   nz,SetTrue
  jr   SetFalse
  ret

; ---------------------------------------------

; ******** - ********
define_2d_macro:
 call MacroExpand
 db   defend_2d_macro-define_2d_macro-4
  ld   b,h
  ld   c,l
  ld  h,d
  ld   l,e
  xor   a
  sbc  hl,bc
defend_2d_macro:

; ---------------------------------------------

; ******** + ********
define_2b_macro:
 call MacroExpand
 db   defend_2b_macro-define_2b_macro-4
  add   hl,de
defend_2b_macro:

; ---------------------------------------------

; ******** * ********
define_2a_macro:
 call MacroExpand
 db   defend_2a_macro-define_2a_macro-4
  call Multiply16
defend_2a_macro:

; ---------------------------------------------

; ******** xor ********
define_78_6f_72_word:
  ld   a,h
  xor  d
  ld   h,a
  ld   a,l
  xor  e
  ld   l,a
  ret

; ---------------------------------------------

; ******** c@ ********
define_63_40_macro:
 call MacroExpand
 db   defend_63_40_macro-define_63_40_macro-4
  ld   l,(hl)
  ld   h,0
defend_63_40_macro:

; ---------------------------------------------

; ******** c! ********
define_63_21_macro:
 call MacroExpand
 db   defend_63_21_macro-define_63_21_macro-4
  ld   (hl),e
defend_63_21_macro:

; ---------------------------------------------

; ******** @ ********
define_40_macro:
 call MacroExpand
 db   defend_40_macro-define_40_macro-4
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
defend_40_macro:

; ---------------------------------------------

; ******** -! ********
define_2d_21_word:
  ld   a,(hl)
  sub  e
  ld   (hl),a
  inc  hl
  ld   a,(hl)
  sbc  a,d
  ld   (hl),a
  ret

; ---------------------------------------------

; ******** ! ********
define_21_macro:
 call MacroExpand
 db   defend_21_macro-define_21_macro-4
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
defend_21_macro:

; ---------------------------------------------

; ******** +! ********
define_2b_21_word:
  ld   a,(hl)
  add  a,e
  ld   (hl),a
  inc  hl
  ld   a,(hl)
  adc  a,d
  ld   (hl),a
  ret

; ---------------------------------------------

; ******** copy ********
define_63_6f_70_79_word:
  push  de
  push  hl
  push  ix
  push  hl
  pop  ix
  ld   c,(ix+4)
  ld   b,(ix+5)
  ld  a,b
  or   c
  jr   z,__copy1
  ld   l,(ix+0)
  ld   h,(ix+1)
  ld   e,(ix+2)
  ld  d,(ix+3)
  ldir
__copy1:
  pop  ix
  pop  hl
  pop  de
  ret

; ---------------------------------------------

; ******** system.editbuffer ********
define_73_79_73_74_65_6d_2e_65_64_69_74_62_75_66_66_65_72_word:
  ld   hl,editBuffer
  ld   de,editBufferSize
  ret

; ---------------------------------------------

; ******** false ********
define_66_61_6c_73_65_macro:
 call MacroExpand
 db   defend_66_61_6c_73_65_macro-define_66_61_6c_73_65_macro-4
  ex   de,hl
  ld   hl,0000
defend_66_61_6c_73_65_macro:

; ---------------------------------------------

; ******** fill ********
define_66_69_6c_6c_word:
  push  de
  push  hl
  ld   a,(hl)
  inc  hl
  inc  hl
  ld   e,(hl)
  inc  hl
  ld   d,(hl)
  inc  hl
  ld   c,(hl)
  inc  hl
  ld   b,(hl)
  ex   de,hl
  ld   e,a
__fill1:
  ld   a,b
  or   c
  jr   z,__fill2
  dec  bc
  ld   (hl),e
  inc  hl
  jr   __fill1
__fill2:
  pop  hl
  pop  de
  ret

; ---------------------------------------------

; ******** i ********
define_69_macro:
 call MacroExpand
 db   defend_69_macro-define_69_macro-4
   pop  hl
   push  hl
defend_69_macro:

; ---------------------------------------------

; ******** pop.ab ********
define_70_6f_70_2e_61_62_macro:
 call MacroExpand
 db   defend_70_6f_70_2e_61_62_macro-define_70_6f_70_2e_61_62_macro-4
  pop  hl
  pop  de
defend_70_6f_70_2e_61_62_macro:

; ---------------------------------------------

; ******** pop.bb ********
define_70_6f_70_2e_62_62_macro:
 call MacroExpand
 db   defend_70_6f_70_2e_62_62_macro-define_70_6f_70_2e_62_62_macro-4
  pop  de
  pop  de
defend_70_6f_70_2e_62_62_macro:

; ---------------------------------------------

; ******** push.ab ********
define_70_75_73_68_2e_61_62_macro:
 call MacroExpand
 db   defend_70_75_73_68_2e_61_62_macro-define_70_75_73_68_2e_61_62_macro-4
   push  de
   push  hl
defend_70_75_73_68_2e_61_62_macro:

; ---------------------------------------------

; ******** a>r ********
define_61_3e_72_macro:
 call MacroExpand
 db   defend_61_3e_72_macro-define_61_3e_72_macro-4
\
  push  hl
defend_61_3e_72_macro:

; ---------------------------------------------

; ******** ; ********
define_3b_macro:
 call MacroExpand
 db   defend_3b_macro-define_3b_macro-4
  ret
defend_3b_macro:

; ---------------------------------------------

; ******** r>a ********
define_72_3e_61_macro:
 call MacroExpand
 db   defend_72_3e_61_macro-define_72_3e_61_macro-4
  pop  hl
defend_72_3e_61_macro:

; ---------------------------------------------

; ******** true ********
define_74_72_75_65_macro:
 call MacroExpand
 db   defend_74_72_75_65_macro-define_74_72_75_65_macro-4
  ex   de,hl
  ld   hl,$FFFF
defend_74_72_75_65_macro:

; ---------------------------------------------

; ******** a>b ********
define_61_3e_62_macro:
 call MacroExpand
 db   defend_61_3e_62_macro-define_61_3e_62_macro-4
  ld   d,h
  ld   e,l
defend_61_3e_62_macro:

; ---------------------------------------------

; ******** b>a ********
define_62_3e_61_macro:
 call MacroExpand
 db   defend_62_3e_61_macro-define_62_3e_61_macro-4
  ld   h,d
  ld   l,e
defend_62_3e_61_macro:

; ---------------------------------------------

; ******** swap ********
define_73_77_61_70_macro:
 call MacroExpand
 db   defend_73_77_61_70_macro-define_73_77_61_70_macro-4
  ex   de,hl
defend_73_77_61_70_macro:

; ---------------------------------------------

; ******** 0= ********
define_30_3d_word:
  ld   a,h
  or   l
  ld   hl,0
  ret  nz
  dec  hl
  ret

; ---------------------------------------------

; ******** 0< ********
define_30_3c_word:
  bit  7,h
  ld   hl,0
  ret  z
  dec  hl
  ret

; ---------------------------------------------

; ******** 0- ********
define_30_2d_word:
__Negate:
  ld   b,h
  ld   c,l
  xor  a
  ld   h,a
  ld   l,a
  sbc  hl,bc
  ret

; ---------------------------------------------

; ******** 1- ********
define_31_2d_macro:
 call MacroExpand
 db   defend_31_2d_macro-define_31_2d_macro-4
  dec  hl
defend_31_2d_macro:

; ---------------------------------------------

; ******** 1+ ********
define_31_2b_macro:
 call MacroExpand
 db   defend_31_2b_macro-define_31_2b_macro-4
  inc  hl
defend_31_2b_macro:

; ---------------------------------------------

; ******** 2/ ********
define_32_2f_macro:
 call MacroExpand
 db   defend_32_2f_macro-define_32_2f_macro-4
  sra  h
  rr   l
defend_32_2f_macro:

; ---------------------------------------------

; ******** 2- ********
define_32_2d_macro:
 call MacroExpand
 db   defend_32_2d_macro-define_32_2d_macro-4
  dec  hl
  dec  hl
defend_32_2d_macro:

; ---------------------------------------------

; ******** 2+ ********
define_32_2b_macro:
 call MacroExpand
 db   defend_32_2b_macro-define_32_2b_macro-4
  inc  hl
  inc  hl
defend_32_2b_macro:

; ---------------------------------------------

; ******** 2* ********
define_32_2a_macro:
 call MacroExpand
 db   defend_32_2a_macro-define_32_2a_macro-4
  add  hl,hl
defend_32_2a_macro:

; ---------------------------------------------

; ******** abs ********
define_61_62_73_word:
  bit  7,h
  ret  z
  jr   __Negate
  ret

; ---------------------------------------------

; ******** bswap ********
define_62_73_77_61_70_macro:
 call MacroExpand
 db   defend_62_73_77_61_70_macro-define_62_73_77_61_70_macro-4
  ld   a,h
  ld   h,l
  ld   l,a
defend_62_73_77_61_70_macro:

; ---------------------------------------------

; ******** not ********
define_6e_6f_74_word:
  ld   a,h
  cpl
  ld   h,a
  ld   a,l
  cpl
  ld  l,a
  ret

; ---------------------------------------------

; ******** breakpoint ********
define_62_72_65_61_6b_70_6f_69_6e_74_macro:
 call MacroExpand
 db   defend_62_72_65_61_6b_70_6f_69_6e_74_macro-define_62_72_65_61_6b_70_6f_69_6e_74_macro-4
  db   $DD,$01
defend_62_72_65_61_6b_70_6f_69_6e_74_macro:

; ---------------------------------------------

; ******** debug ********
define_64_65_62_75_67_word:
  push  bc
  push  de
  push  hl
  push  de
  ex   de,hl
  ld   b,$C0
  ld   hl,23+23*32
  call  __DisplayHexInteger
  pop  de
  ld   b,$80
  ld   hl,28+23*32
  call  __DisplayHexInteger
  pop  hl
  pop  de
  pop  bc
  ret
__DisplayHexInteger:
  ld   a,d
  call  __DisplayHexByte
  ld   a,e
__DisplayHexByte:
  push  af
  rrca
  rrca
  rrca
  rrca
  call __DisplayHexNibble
  pop  af
__DisplayHexNibble:
  and  $0F
  cp   10
  jr   c,__DisplayIntCh
  sub  57
__DisplayIntCh:
  add  a,48
  or   b
  call IOWriteCharacter
  inc  hl
  ret

; ---------------------------------------------

; ******** halt ********
define_68_61_6c_74_macro:
 call MacroExpand
 db   defend_68_61_6c_74_macro-define_68_61_6c_74_macro-4
HaltProcessor:
  halt
  jr   HaltProcessor
defend_68_61_6c_74_macro:

; ---------------------------------------------

; ******** system.xmacro ********
define_73_79_73_74_65_6d_2e_78_6d_61_63_72_6f_word:
MacroExpand:
  pop  hl
  ret

; ---------------------------------------------

; ******** system.info ********
define_73_79_73_74_65_6d_2e_69_6e_66_6f_word:
SISystemInformation:
SINextDictionary:
 dw  DictionaryStart
SINextFreeProgram:
 dw   ProgramSpace
SINextFreePage:
 db   0,0
SIRuntimeAddress:
 dw   HaltProcessor
SIStack:
 dw   Z80Stack
SIDictionaryBase:
 dw   DictionaryStart

; ---------------------------------------------

