;
;  **** AUTOMATICALLY GENERATED ****;
;
;
; File : words\compilehelpers.asm
;
definition_63_2c:
  ld   a,l
  jp   CompileByte
definition_2c:
  jp   CompileWord
definition_61_2c:
  ld   a,h
  or   a
  call  nz,CompileByte
  ld   a,l
  jp   CompileByte
definition_6d_77_6f_72_64_73:
  xor  a
  jp   SetDefaultCreateBits
definition_6d_61_63_72_6f_73:
  ld   a,$80
  jp   SetDefaultCreateBits
definition_70_72_69_76_61_74_65_macro:
definition_6d_61_6b_65_2e_70_72_69_76_61_74_65:
MakePrivate:
  ld   a,$40
  jp   SetLastEntryBit
definition_64_6f_2e_73_6f_75_72_63_65:
  jp   CompileBlock
;
; File : words\crunch.asm
;
definition_63_72_75_6e_63_68:
  push ix
  ld   ix,(SVDictionaryBase)
__crunch_loop:
  ld  a,(ix+0)
  or   a
  jr   z,__crunch_exit
  bit  6,(ix+4)
  jr   z,__crunch_next
  ld   hl,(SVNextDictionaryFree)
  push  ix
  pop  bc
  xor  a
  sbc  hl,bc
  ld   c,l
  ld   b,h
  push  ix
  pop  de
  ld   l,(ix+0)
  ld   h,0
  add  hl,de
  ldir
  jr   __crunch_loop
__crunch_next:
  ld   e,(ix+0)
  ld   d,0
  add  ix,de
  jr   __crunch_loop
__crunch_exit:
  ld   (SVNextDictionaryFree),ix
  pop  ix
  ret
;
; File : words\data.asm
;
definition_66_69_6c_6c:
  ld   a,b
  or   c
  ret  z
  push  bc
  push  hl
__fill1:ld   (hl),e
  inc  hl
  dec  bc
  ld   a,b
  or   c
  jr   nz,__fill1
  pop  hl
  pop  bc
  ret
definition_63_6f_70_79:
  push  bc
  push  de
  push  hl
  ld   a,b
  or   c
  jr   z,__copyExit
  xor  a
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a
  jr   z,__copy2
  ex   de,hl
  ldir
__copyExit:
  pop  hl
  pop  de
  pop  bc
  ret
__copy2:
  add  hl,bc
  ex   de,hl
  add  hl,bc
  dec  de
  dec  hl
  lddr
  jr   __copyExit
;
; File : words\debug.asm
;
definition_78_2e_64_65_62_75_67:
  ld   hl,(AWork)
  ld   de,(BWork)
  ld   bc,(CWork)
definition_64_65_62_75_67:
  push  bc
  push  de
  push  hl
  push  bc
  push  de
  ex   de,hl
  ld   b,'A'+$40
  ld   c,$40
  ld   hl,12+23*32
  call  __DisplayHexInteger
  pop  de
  ld   b,'B'+$40
  ld   c,$C0
  ld   hl,19+23*32
  call  __DisplayHexInteger
  pop  de
  ld   b,'C'+$40
  ld   c,$00
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
definition_2e_68:
  ld   a,' '
  call  IOPrintCharacter
  ld   a,h
  call  __PrintByte
  ld   a,l
__PrintByte:
  push  af
  rrc  a
  rrc  a
  rrc  a
  rrc  a
  call  __PrintNibble
  pop  af
__PrintNibble:
  and  15
  cp   10
  jr   c,__PNIsDigit
  sub  48+9
__PNIsDigit:
  add  48+$40
  jp   IOPrintCharacter
;
; File : words\math.asm
;
definition_2a:
  jp   Multiply16
definition_2f:
  push   de
  call   DivideMod16
  ex    de,hl
  pop   de
  ret
definition_6d_6f_64:
  push   de
  call   DivideMod16
  pop   de
  ret
;
; File : words\misc.asm
;
definition_68_61_6c_74:
  jp   HaltCode
definition_73_70_2e_72_65_73_65_74:
  pop  ix
  ld   sp,stackTop
  jp   (ix)
definition_63_6c_72_2e_73_63_72_65_65_6e:
  jp   IOClearScreen
definition_63_75_72_73_6f_72_21:
  jp   IOSetCursor
definition_73_63_72_65_65_6e_21:
  ld   a,e
  jp   IOWriteCharacter
definition_6b_65_79_40:
  call  IOScanKeyboard
  ld   l,a
  ld   h,0
  ret
definition_62_75_66_66_65_72:
  ex   de,hl
  ld   hl,buffer
  ret
definition_62_75_66_66_65_72_2e_73_69_7a_65:
  ex   de,hl
  ld   hl,bufferSize
  ret
definition_73_79_73_2e_69_6e_66_6f:
  ex   de,hl
  ld   hl,SystemVariables
  ret
;
; File : words\variable.asm
;
definition_76_61_72_69_61_62_6c_65_macro:
  call  cbGetWord
  jr   c,__varError
  inc  (hl)
  ld   a,'@'
  call  __varCreate
  ld   a,'!'
  call  __varCreate
  ld   a,'&'
  call  __varCreate
  ld   hl,0
  call  CompileWord
  ret
__varCreate:
  push  hl
  ld   e,(hl)
  ld   d,0
  add  hl,de
  and  $3F
  ld   (hl),a
  pop  hl
  call  DefineNewWord
  ld   a,$C0
  call  SetLastEntryBit
  ret
__varError:
  ld   hl,__varMissingMsg
  jp   ErrorHandler
__varMissingMsg:
  db   __varMissingMsgEnd-__varMissingMsg+1
  db   "MISSING VARIABLE NAME"
__varMissingMsgEnd:
VARGenerateCode:
  push  de
  push  hl
  push  hl
  ld   a,(hl)
  and  $3F
  ld   e,a
  ld   d,0
  add  hl,de
  ld   a,(hl)
  and  $3F
  pop  hl
  dec  hl
  dec  hl
  dec  hl
  ld   e,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,e
  cp   '@' & $3F
  call  z,__varReadCode
  cp   '!' & $3F
  call  z,__varWriteCode
  cp   '&' & $3F
  call  z,__varAddressCode
  pop  hl
  pop  de
  ret
__varReadCode:
  push  af
  ld   a,$EB
  call  CompileByte
  ld   a,$2A
  call  CompileByte
  call  CompileWord
  pop  af
  ret
__varWriteCode:
  push  af
  ld   a,$22
  call  CompileByte
  call  CompileWord
  pop  af
  ret
__varAddressCode:
  push  af
  ld   a,$EB
  call  CompileByte
  ld   a,$21
  call  CompileByte
  call  CompileWord
  pop  af
  ret
