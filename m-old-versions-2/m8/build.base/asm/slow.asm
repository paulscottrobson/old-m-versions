;
;		automatically generated
;
; ******** : ********
define_immediate_3a:
  xor  a
  call CreateDefinition
  ret
CreateDefinition:
  push  af
  push  bc
  push  de
  push  hl
  push  ix
  push  af
  call  ParseWord
  pop  af
  push  hl
  push   af
  ld   a,h
  or   l
  jp   z,ERR_NoDefName
  ld   ix,(SINextFreeDictionary)
  ld   hl,(SINextFreeProgram)
  ld   (ix+1),l
  ld   (ix+2),h
  ld   a,(SINextFreePage)
  ld   (ix+3),a
  pop  af
  ld   (ix+4),a
  ld   bc,5
  add  ix,bc
  pop  hl
__CopyName:
  ld   a,(hl)
  ld   (ix+0),a
  inc  ix
  inc  hl
  inc  c
  or   a
  jr   nz,__CopyName
  dec  c
  dec  ix
  ld   hl,(SINextFreeDictionary)
  ld   (hl),c
  ld   (ix+0),0
  ld   (SINextFreeDictionary),ix
  dec  ix
  set  7,(ix+0)
  pop  ix
  pop  hl
  pop  de
  pop  bc
  pop  af
  ret

; ---------------------------------------------

; ******** compiler.compilebyte ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_63_6f_6d_70_69_6c_65_62_79_74_65:
  ld   a,l
CompileByte:
  push  hl
  ld   hl,(SINextFreeProgram)
  ld   (hl),a
  inc  hl
  ld   (SINextFreeProgram),hl
  pop  hl
  ret

; ---------------------------------------------

; ******** compiler.word ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_77_6f_72_64:
CompileOneWord:
  push  de
  push hl
  push  ix
  push hl
  pop  ix
  call  SearchDictionary
  ld   a,h
  or   l
  jr   nz,__COWDirect
  push  ix
  pop   hl
  call  EvaluateConstant
  jr   nc,__CWConstant
  jp   ERR_UnknownWord
__COWDirect:
  push  hl
  pop  ix
  ld   a,(ix+4)
  and  $7F
  jr   z,__CWStandard
  bit  6,a
  jr   z,__CWMacroExpansion
  cp   $40
  jr   z,__CWVariable
  cp   $41
  jr   z,__CWImmediate
__CWExit:
  pop  ix
  pop  hl
  pop  de
  ret
__CWStandard:
  ld   a,$CD
  call  CompileByte
  ld   l,(ix+1)
  ld   h,(ix+2)
  call  CompileWord
  jr   __CWExit
__CWMacroExpansion:
  ld   b,a
  ld   l,(ix+1)
  ld   h,(ix+2)
__CWMacroLoop:
  ld   a,(hl)
  inc  hl
  call  CompileByte
  djnz  __CWMacroLoop
  jr   __CWExit
__CWVariable:
  ld   l,(ix+1)
  ld   h,(ix+2)
__CWConstant:
  ld   a,$EB
  call  CompileByte
  ld   a,$21
  call  CompileByte
  call  CompileWord
  jr   __CWExit
__CWImmediate:
  ld   l,(ix+1)
  ld   h,(ix+2)
  call  __CWJPHL
  jr   __CWExit
__CWJPHL:
  jp   (hl)
EvaluateConstant:
  push  bc
  push  de
  push  ix
  ld   ix,$0000
  ld   c,10
  ex   de,hl
  ld   a,(de)
  cp   '$'
  jr   nz,__ECNotHex
  ld   c,16
  inc  de
__ECNotHex:
__ECLoop:
  push de
  push  ix
  pop  de
  ld   ix,$0000
  ld   b,c
__ECMultiply:
  bit  0,b
  jr   z,__ECMult1
  add  ix,de
__ECMult1:
  ex   de,hl
  add  hl,hl
  ex   de,hl
  srl  b
  ld   a,b
  or   a
  jr   nz,__ECMultiply
  pop  de
  db   $DD,$01
  ld   a,(de)
  inc  de
  cp   '0'
  jr   c,__ECExit
  cp   '9'+1
  jr   c,__ECDigit1
  cp   'A'
  jr   c,__ECExit
  cp   'F'+1
  ccf
  jr   c,__ECExit
  sub  7
__ECDigit1:
  sub  '0'
  cp   c
  ccf
  jr   c,__ECExit
  push  de
  ld   e,a
  ld   d,0
  add  ix,de
  pop  de
  ld   a,(de)
  or   a
  jr   nz,__ECLoop
__ECExitGood:
  xor  a
  push  ix
  pop  hl
__ECExit:
  pop  ix
  pop  de
  pop  bc
  ret

; ---------------------------------------------

; ******** compiler.stream ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_73_74_72_65_61_6d:
CompileStream:
  push  hl
__CSTLoop:
  call  ParseWord
  ld   a,h
  or   l
  jr   z,__CSTExit
  call  CompileOneWord
  jr   __CSTLoop
__CSTExit:
  pop  hl
  ret
CompileCode:
  ld   (ParseAddress),hl
  jr   CompileStream

; ---------------------------------------------

; ******** compiler.compileword ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_63_6f_6d_70_69_6c_65_77_6f_72_64:
CompileWord:
  ld   a,l
  call  CompileByte
  ld   a,h
  call  CompileByte
  ret

; ---------------------------------------------

; ******** compiler.find ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_66_69_6e_64:
SearchDictionary:
  ld   (__SDWordToCheck),hl
  ld   hl,$0000
  ld   (__SDResult),hl
  ld   hl,(SIDictionaryStart)
__SDLoop:
  ld   a,(hl)
  or   a
  jr   nz,__SDNext
  ld   hl,(__SDResult)
  ret
__SDNext:
  call  __SDCompare
  ld   a,(hl)
  ld   c,a
  ld   b,0
  add  hl,bc
  jr   __SDLoop
__SDCompare:
  push  de
  push  hl
  ld   de,(__SDWordToCheck)
  inc  hl
  inc  hl
  inc  hl
  inc  hl
  inc  hl
__SDCLoop:
  ld   a,(de)
  xor  (hl)
  and  $7F
  jr   nz,__SDExit
  ld   a,(hl)
  inc  hl
  inc  de
  bit  7,a
  jr   z,__SDCLoop
  pop  hl
  pop  de
  ld   (__SDResult),hl
  ret
__SDExit:
  pop  hl
  pop  de
  ret
__SDWordToCheck:
  dw   0
__SDResult:
  dw   0

; ---------------------------------------------

; ******** compiler.parseaddress ********
define_variable_63_6f_6d_70_69_6c_65_72_2e_70_61_72_73_65_61_64_64_72_65_73_73:
ParseAddress:
  dw    0

; ---------------------------------------------

; ******** compiler.parseword ********
define_slow_63_6f_6d_70_69_6c_65_72_2e_70_61_72_73_65_77_6f_72_64:
ParseWord:
  call  __PWGet
  ld   hl,$0000
  or   a
  ret  z
  cp   ' '
  jr   z,ParseWord
  push  de
  ld   de,ParseBuffer
__PW_Copy:
  cp   'a'
  jr   c,__PW_NotLC
  cp   'z'+1
  jr   nc,__PW_NotLC
  sub  32
__PW_NotLC:
  ld   (de),a
  inc  de
  call  __PWGet
  cp   ' '+1
  jr   nc,__PW_Copy
  xor  a
  ld   (de),a
  pop  de
  ld   hl,ParseBuffer
  ret
__PWGet:ld   hl,(ParseAddress)
  ld   a,(hl)
  or   a
  ret  z
  inc  hl
  ld   (ParseAddress),hl
  cp   ' '
  ret  nc
  ld   a,' '
  ret
ParseBuffer:
  ds   64

; ---------------------------------------------

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
  add   hl,de
end_define_macro_2b:

; ---------------------------------------------

; ******** * ********
define_macro_2a:
  call Multiply16
end_define_macro_2a:

; ---------------------------------------------

; ******** c@ ********
define_macro_63_40:
  ld   l,(hl)
  ld   h,0
end_define_macro_63_40:

; ---------------------------------------------

; ******** c! ********
define_macro_63_21:
  ld   (hl),e
end_define_macro_63_21:

; ---------------------------------------------

; ******** @ ********
define_macro_40:
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
end_define_macro_40:

; ---------------------------------------------

; ******** ! ********
define_macro_21:
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
end_define_macro_21:

; ---------------------------------------------

; ******** false ********
define_macro_66_61_6c_73_65:
  ex   de,hl
  ld   hl,$0000
end_define_macro_66_61_6c_73_65:

; ---------------------------------------------

; ******** pop.ab ********
define_macro_70_6f_70_2e_61_62:
  pop  hl
  pop  de
end_define_macro_70_6f_70_2e_61_62:

; ---------------------------------------------

; ******** pop.bb ********
define_macro_70_6f_70_2e_62_62:
  pop  de
  pop  de
end_define_macro_70_6f_70_2e_62_62:

; ---------------------------------------------

; ******** push.ab ********
define_macro_70_75_73_68_2e_61_62:
   push  de
   push  hl
end_define_macro_70_75_73_68_2e_61_62:

; ---------------------------------------------

; ******** a>r ********
define_macro_61_3e_72:
  push  hl
end_define_macro_61_3e_72:

; ---------------------------------------------

; ******** ; ********
define_macro_3b:
  ret
end_define_macro_3b:

; ---------------------------------------------

; ******** r>a ********
define_macro_72_3e_61:
  ex   de,hl
  pop  hl
end_define_macro_72_3e_61:

; ---------------------------------------------

; ******** true ********
define_macro_74_72_75_65:
  ex   de,hl
  ld   hl,$FFFF
end_define_macro_74_72_75_65:

; ---------------------------------------------

; ******** a>b ********
define_macro_61_3e_62:
  ld   d,h
  ld   e,l
end_define_macro_61_3e_62:

; ---------------------------------------------

; ******** b>a ********
define_macro_62_3e_61:
  ld   h,d
  ld   l,e
end_define_macro_62_3e_61:

; ---------------------------------------------

; ******** swap ********
define_macro_73_77_61_70:
  ex   de,hl
end_define_macro_73_77_61_70:

; ---------------------------------------------

; ******** 1- ********
define_macro_31_2d:
  dec  hl
end_define_macro_31_2d:

; ---------------------------------------------

; ******** 1+ ********
define_macro_31_2b:
  inc  hl
end_define_macro_31_2b:

; ---------------------------------------------

; ******** 2/ ********
define_macro_32_2f:
  sra  h
  rr   l
end_define_macro_32_2f:

; ---------------------------------------------

; ******** 2- ********
define_macro_32_2d:
  dec  hl
  dec  hl
end_define_macro_32_2d:

; ---------------------------------------------

; ******** 2+ ********
define_macro_32_2b:
  inc  hl
  inc  hl
end_define_macro_32_2b:

; ---------------------------------------------

; ******** 2* ********
define_macro_32_2a:
  add  hl,hl
end_define_macro_32_2a:

; ---------------------------------------------

; ******** bswap ********
define_macro_62_73_77_61_70:
  ld   a,h
  ld   h,l
  ld   l,a
end_define_macro_62_73_77_61_70:

; ---------------------------------------------

; ******** compiler.boot ********
define_immediate_63_6f_6d_70_69_6c_65_72_2e_62_6f_6f_74:
  push  hl
  ld   hl,(SINextFreeProgram)
  ld   (SIRunTimeAddress),hl
  pop  hl
  ret

; ---------------------------------------------

; ******** breakpoint ********
define_macro_62_72_65_61_6b_70_6f_69_6e_74:
  db   $DD,$01
end_define_macro_62_72_65_61_6b_70_6f_69_6e_74:

; ---------------------------------------------

; ******** (* ********
define_immediate_28_2a:
  push  hl
__CommentSkip:
  call  ParseWord
  ld   a,h
  or   l
  jp   z,ERR_UnclosedComment
  ld   a,(hl)
  cp   '*'
  jr   nz,__CommentSkip
  inc  hl
  ld   a,(hl)
  cp   ')'
  jr   nz,__CommentSkip
  inc  hl
  ld   a,(hl)
  or   a
  jr   nz,__CommentSkip
  pop  hl
  ret

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
HaltProcessor:
  halt
  jr   HaltProcessor
end_define_macro_68_61_6c_74:

; ---------------------------------------------

; ******** system.info ********
define_variable_73_79_73_74_65_6d_2e_69_6e_66_6f:
SISystemInformation:
SINextFreeDictionary:
 dw   DictionarySpace
SINextFreeProgram:
 dw   ProgramSpace
SINextFreePage:
 db   0,0
SIRunTimeAddress:
 dw   StartCompile
SIStack:
 dw   Z80Stack
SIDictionaryStart:
 dw   DictionaryBase

; ---------------------------------------------

