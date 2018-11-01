;
;		automatically generated
;
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

; ******** 2/ ********
define_32_2f_macro:
 db   defend_32_2f_macro-define_32_2f_macro-1
  sra  h
  rr   l
defend_32_2f_macro:

; ---------------------------------------------

; ******** a>b ********
define_61_3e_62_macro:
 db   defend_61_3e_62_macro-define_61_3e_62_macro-1
  ld   d,h
  ld   e,l
defend_61_3e_62_macro:

; ---------------------------------------------

; ******** breakpoint ********
define_62_72_65_61_6b_70_6f_69_6e_74_macro:
 db   defend_62_72_65_61_6b_70_6f_69_6e_74_macro-define_62_72_65_61_6b_70_6f_69_6e_74_macro-1
  db   $DD,$01
defend_62_72_65_61_6b_70_6f_69_6e_74_macro:

; ---------------------------------------------

; ******** b>a ********
define_62_3e_61_macro:
 db   defend_62_3e_61_macro-define_62_3e_61_macro-1
  ld   h,d
  ld   l,e
defend_62_3e_61_macro:

; ---------------------------------------------

; ******** c@ ********
define_63_40_macro:
 db   defend_63_40_macro-define_63_40_macro-1
  ld   l,(hl)
  ld   h,0
defend_63_40_macro:

; ---------------------------------------------

; ******** c! ********
define_63_21_macro:
 db   defend_63_21_macro-define_63_21_macro-1
  ld   (hl),e
defend_63_21_macro:

; ---------------------------------------------

; ******** debug ********
define_64_65_62_75_67_word:
  push  bc
  push  de
  push  hl
  push  de
  ex   de,hl
  ld   b,'A'+$40
  ld   c,$40
  ld   hl,19+23*32
  call  __DisplayHexInteger
  pop  de
  ld   b,'B'+$40
  ld   c,$C0
  ld   hl,26+23*32
  call  __DisplayHexInteger
  pop  hl
  pop  de
  pop  bc
  ret
__DisplayHexInteger:
  ld   a,b
  call  IOWriteCharacter
  inc  hl
  ld   a,':'+$80
  call  IOWriteCharacter
  inc  hl
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
  or   c
  call IOWriteCharacter
  inc  hl
  ret

; ---------------------------------------------

; ******** halt ********
define_68_61_6c_74_macro:
 db   defend_68_61_6c_74_macro-define_68_61_6c_74_macro-1
HaltProcessor:
  halt
  jr   HaltProcessor
defend_68_61_6c_74_macro:

; ---------------------------------------------

; ******** inkey ********
define_69_6e_6b_65_79_word:
  call  IOScanKeyboard
  ld   l,a
  ld   h,0
  ret

; ---------------------------------------------

; ******** nand ********
define_6e_61_6e_64_word:
  ld   a,h
  and  d
  cpl
  ld   h,a
  ld   a,l
  and  e
  cpl
  ld   l,a
  ret

; ---------------------------------------------

; ******** pop.ab ********
define_70_6f_70_2e_61_62_macro:
 db   defend_70_6f_70_2e_61_62_macro-define_70_6f_70_2e_61_62_macro-1
  pop  hl
  pop  de
defend_70_6f_70_2e_61_62_macro:

; ---------------------------------------------

; ******** pop.bb ********
define_70_6f_70_2e_62_62_macro:
 db   defend_70_6f_70_2e_62_62_macro-define_70_6f_70_2e_62_62_macro-1
  pop  de
  pop  de
defend_70_6f_70_2e_62_62_macro:

; ---------------------------------------------

; ******** p@ ********
define_70_40_macro:
 db   defend_70_40_macro-define_70_40_macro-1
  ld   b,h
  ld   c,l
  in   l,(c)
  ld   h,0
defend_70_40_macro:

; ---------------------------------------------

; ******** p! ********
define_70_21_macro:
 db   defend_70_21_macro-define_70_21_macro-1
  ld   b,h
  ld   c,l
  out  (c),e
defend_70_21_macro:

; ---------------------------------------------

; ******** push.ab ********
define_70_75_73_68_2e_61_62_macro:
 db   defend_70_75_73_68_2e_61_62_macro-define_70_75_73_68_2e_61_62_macro-1
   push  de
   push  hl
defend_70_75_73_68_2e_61_62_macro:

; ---------------------------------------------

; ******** @ ********
define_40_macro:
 db   defend_40_macro-define_40_macro-1
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
defend_40_macro:

; ---------------------------------------------

; ******** a>r ********
define_61_3e_72_macro:
 db   defend_61_3e_72_macro-define_61_3e_72_macro-1
  push  hl
defend_61_3e_72_macro:

; ---------------------------------------------

; ******** ! ********
define_21_macro:
 db   defend_21_macro-define_21_macro-1
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
defend_21_macro:

; ---------------------------------------------

; ******** + ********
define_2b_macro:
 db   defend_2b_macro-define_2b_macro-1
  add   hl,de
defend_2b_macro:

; ---------------------------------------------

; ******** ; ********
define_3b_macro:
 db   defend_3b_macro-define_3b_macro-1
  ret
defend_3b_macro:

; ---------------------------------------------

; ******** r>a ********
define_72_3e_61_macro:
 db   defend_72_3e_61_macro-define_72_3e_61_macro-1
  pop  hl
defend_72_3e_61_macro:

; ---------------------------------------------

; ******** cursor! ********
define_63_75_72_73_6f_72_21_word:
  jp   IOSetCursor

; ---------------------------------------------

; ******** screen! ********
define_73_63_72_65_65_6e_21_word:
  ld   a,e
  jp   IOWriteCharacter

; ---------------------------------------------

; ******** swap ********
define_73_77_61_70_macro:
 db   defend_73_77_61_70_macro-define_73_77_61_70_macro-1
  ex   de,hl
defend_73_77_61_70_macro:

; ---------------------------------------------

; ******** sysinfo ********
define_73_79_73_69_6e_66_6f_word:
SystemInfo:
 ld   hl,SystemInfo
 ret
 org  SystemInfo+8
SIAProgramPointer:
 dw   ProgramSpace
SIAProgramPage:
 db   0,0
SIARuntimeAddress:
 dw   HaltProcessor
SIAScreenWidth:
 db   IOScreenWidth,0
SIAScreenHeight:
 db   IOScreenHeight,0

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
 db   defend_31_2d_macro-define_31_2d_macro-1
  dec  hl
defend_31_2d_macro:

; ---------------------------------------------

; ******** 1+ ********
define_31_2b_macro:
 db   defend_31_2b_macro-define_31_2b_macro-1
  inc  hl
defend_31_2b_macro:

; ---------------------------------------------

; ******** 2- ********
define_32_2d_macro:
 db   defend_32_2d_macro-define_32_2d_macro-1
  dec  hl
  dec  hl
defend_32_2d_macro:

; ---------------------------------------------

; ******** 2+ ********
define_32_2b_macro:
 db   defend_32_2b_macro-define_32_2b_macro-1
  inc  hl
  inc  hl
defend_32_2b_macro:

; ---------------------------------------------

; ******** 2* ********
define_32_2a_macro:
 db   defend_32_2a_macro-define_32_2a_macro-1
  add  hl,hl
defend_32_2a_macro:

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

; ******** - ********
define_2d_macro:
 db   defend_2d_macro-define_2d_macro-1
  ld   b,h
  ld   c,l
  ld  h,d
  ld   l,e
  xor   a
  sbc  hl,bc
defend_2d_macro:

; ---------------------------------------------

; ******** abs ********
define_61_62_73_word:
  bit  7,h
  ret  z
  jr   __Negate
  ret

; ---------------------------------------------

; ******** clrscreen ********
define_63_6c_72_73_63_72_65_65_6e_word:
  jp   IOClearScreen

; ---------------------------------------------

; ******** false ********
define_66_61_6c_73_65_macro:
 db   defend_66_61_6c_73_65_macro-define_66_61_6c_73_65_macro-1
  ex   de,hl
  ld   hl,0000
defend_66_61_6c_73_65_macro:

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

; ******** true ********
define_74_72_75_65_macro:
 db   defend_74_72_75_65_macro-define_74_72_75_65_macro-1
  ex   de,hl
  ld   hl,$FFFF
defend_74_72_75_65_macro:

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

; ******** bswap ********
define_62_73_77_61_70_macro:
 db   defend_62_73_77_61_70_macro-define_62_73_77_61_70_macro-1
  ld   a,h
  ld   h,l
  ld   l,a
defend_62_73_77_61_70_macro:

; ---------------------------------------------

; ******** buffer ********
define_62_75_66_66_65_72_word:
  ld   hl,editBuffer
  ld   de,editBufferSize
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

; ******** mod ********
define_6d_6f_64_word:
  push   de
  call   DivideMod16
  pop   de
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

; ******** * ********
define_2a_macro:
 db   defend_2a_macro-define_2a_macro-1
  call Multiply16
defend_2a_macro:

; ---------------------------------------------

