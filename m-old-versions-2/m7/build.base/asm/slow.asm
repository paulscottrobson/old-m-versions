;
;		automatically generated
;
; ******** con.clear.screen ********
define_63_6f_6e_2e_63_6c_65_61_72_2e_73_63_72_65_65_6e_slow:
  jp   IOClearScreen

; ---------------------------------------------

; ******** con.cursor! ********
define_63_6f_6e_2e_63_75_72_73_6f_72_21_slow:
  jp   IOSetCursor

; ---------------------------------------------

; ******** con.screen! ********
define_63_6f_6e_2e_73_63_72_65_65_6e_21_slow:
  ld   a,e
  jp   IOWriteCharacter

; ---------------------------------------------

; ******** - ********
define_2d_macro:
 call expandMacro
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
 call expandMacro
 db   defend_2b_macro-define_2b_macro-4
  add   hl,de
defend_2b_macro:

; ---------------------------------------------

; ******** * ********
define_2a_macro:
 call expandMacro
 db   defend_2a_macro-define_2a_macro-4
  call Multiply16
defend_2a_macro:

; ---------------------------------------------

; ******** c@ ********
define_63_40_macro:
 call expandMacro
 db   defend_63_40_macro-define_63_40_macro-4
  ld   l,(hl)
  ld   h,0
defend_63_40_macro:

; ---------------------------------------------

; ******** c! ********
define_63_21_macro:
 call expandMacro
 db   defend_63_21_macro-define_63_21_macro-4
  ld   (hl),e
defend_63_21_macro:

; ---------------------------------------------

; ******** @ ********
define_40_macro:
 call expandMacro
 db   defend_40_macro-define_40_macro-4
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
defend_40_macro:

; ---------------------------------------------

; ******** ! ********
define_21_macro:
 call expandMacro
 db   defend_21_macro-define_21_macro-4
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
defend_21_macro:

; ---------------------------------------------

; ******** false ********
define_66_61_6c_73_65_macro:
 call expandMacro
 db   defend_66_61_6c_73_65_macro-define_66_61_6c_73_65_macro-4
  ex   de,hl
  ld   hl,0000
defend_66_61_6c_73_65_macro:

; ---------------------------------------------

; ******** pop.ab ********
define_70_6f_70_2e_61_62_macro:
 call expandMacro
 db   defend_70_6f_70_2e_61_62_macro-define_70_6f_70_2e_61_62_macro-4
  pop  hl
  pop  de
defend_70_6f_70_2e_61_62_macro:

; ---------------------------------------------

; ******** pop.bb ********
define_70_6f_70_2e_62_62_macro:
 call expandMacro
 db   defend_70_6f_70_2e_62_62_macro-define_70_6f_70_2e_62_62_macro-4
  pop  de
  pop  de
defend_70_6f_70_2e_62_62_macro:

; ---------------------------------------------

; ******** push.ab ********
define_70_75_73_68_2e_61_62_macro:
 call expandMacro
 db   defend_70_75_73_68_2e_61_62_macro-define_70_75_73_68_2e_61_62_macro-4
   push  de
   push  hl
defend_70_75_73_68_2e_61_62_macro:

; ---------------------------------------------

; ******** a>r ********
define_61_3e_72_macro:
 call expandMacro
 db   defend_61_3e_72_macro-define_61_3e_72_macro-4
  push  hl
defend_61_3e_72_macro:

; ---------------------------------------------

; ******** ; ********
define_3b_macro:
 call expandMacro
 db   defend_3b_macro-define_3b_macro-4
  ret
defend_3b_macro:

; ---------------------------------------------

; ******** r>a ********
define_72_3e_61_macro:
 call expandMacro
 db   defend_72_3e_61_macro-define_72_3e_61_macro-4
  pop  hl
defend_72_3e_61_macro:

; ---------------------------------------------

; ******** true ********
define_74_72_75_65_macro:
 call expandMacro
 db   defend_74_72_75_65_macro-define_74_72_75_65_macro-4
  ex   de,hl
  ld   hl,$FFFF
defend_74_72_75_65_macro:

; ---------------------------------------------

; ******** a>b ********
define_61_3e_62_macro:
 call expandMacro
 db   defend_61_3e_62_macro-define_61_3e_62_macro-4
  ld   d,h
  ld   e,l
defend_61_3e_62_macro:

; ---------------------------------------------

; ******** b>a ********
define_62_3e_61_macro:
 call expandMacro
 db   defend_62_3e_61_macro-define_62_3e_61_macro-4
  ld   h,d
  ld   l,e
defend_62_3e_61_macro:

; ---------------------------------------------

; ******** swap ********
define_73_77_61_70_macro:
 call expandMacro
 db   defend_73_77_61_70_macro-define_73_77_61_70_macro-4
  ex   de,hl
defend_73_77_61_70_macro:

; ---------------------------------------------

; ******** 1- ********
define_31_2d_macro:
 call expandMacro
 db   defend_31_2d_macro-define_31_2d_macro-4
  dec  hl
defend_31_2d_macro:

; ---------------------------------------------

; ******** 1+ ********
define_31_2b_macro:
 call expandMacro
 db   defend_31_2b_macro-define_31_2b_macro-4
  inc  hl
defend_31_2b_macro:

; ---------------------------------------------

; ******** 2/ ********
define_32_2f_macro:
 call expandMacro
 db   defend_32_2f_macro-define_32_2f_macro-4
  sra  h
  rr   l
defend_32_2f_macro:

; ---------------------------------------------

; ******** 2- ********
define_32_2d_macro:
 call expandMacro
 db   defend_32_2d_macro-define_32_2d_macro-4
  dec  hl
  dec  hl
defend_32_2d_macro:

; ---------------------------------------------

; ******** 2+ ********
define_32_2b_macro:
 call expandMacro
 db   defend_32_2b_macro-define_32_2b_macro-4
  inc  hl
  inc  hl
defend_32_2b_macro:

; ---------------------------------------------

; ******** 2* ********
define_32_2a_macro:
 call expandMacro
 db   defend_32_2a_macro-define_32_2a_macro-4
  add  hl,hl
defend_32_2a_macro:

; ---------------------------------------------

; ******** bswap ********
define_62_73_77_61_70_macro:
 call expandMacro
 db   defend_62_73_77_61_70_macro-define_62_73_77_61_70_macro-4
  ld   a,h
  ld   h,l
  ld   l,a
defend_62_73_77_61_70_macro:

; ---------------------------------------------

; ******** breakpoint ********
define_62_72_65_61_6b_70_6f_69_6e_74_macro:
 call expandMacro
 db   defend_62_72_65_61_6b_70_6f_69_6e_74_macro-define_62_72_65_61_6b_70_6f_69_6e_74_macro-4
  db   $DD,$01
defend_62_72_65_61_6b_70_6f_69_6e_74_macro:

; ---------------------------------------------

; ******** debug ********
define_64_65_62_75_67_slow:
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
 call expandMacro
 db   defend_68_61_6c_74_macro-define_68_61_6c_74_macro-4
HaltProcessor:
  halt
  jr   HaltProcessor
defend_68_61_6c_74_macro:

; ---------------------------------------------

; ******** system.dictionary.base ********
define_73_79_73_74_65_6d_2e_64_69_63_74_69_6f_6e_61_72_79_2e_62_61_73_65_slow:
  ld  hl,DictionaryBase
  ld  de,DictionaryEnd
  ret

; ---------------------------------------------

; ******** system.info ********
define_73_79_73_74_65_6d_2e_69_6e_66_6f_slow:
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
SIAStack:
 dw   Z80Stack
SIADictionaryBase:
 dw   DictionaryBase
SIADictionaryNextFree:
 dw   DictionaryBase
SIADictionaryEnd:
 dw   DictionaryEnd

; ---------------------------------------------

; ******** system.xmacro ********
define_73_79_73_74_65_6d_2e_78_6d_61_63_72_6f_slow:
expandMacro:
  pop  hl
  ret

; ---------------------------------------------

