
; **** .h word ****
definition_2e_68:
  jp   IOPrintHex

; **** + macro ****
definition_2b_macro:
 db end_definition_2b_macro-definition_2b_macro-1
  add  hl,de
end_definition_2b_macro:

; **** nand word ****
definition_6e_61_6e_64:
  ld   a,h
  and  d
  cpl
  ld   h,a
  ld   a,l
  and  e
  cpl
  ld   l,a
  ret

; **** 0< word ****
definition_30_3c:
  bit  7,h
  ld   hl,0
  ret  z
  dec  hl
  ret

; **** 0= word ****
definition_30_3d:
  ld   a,h
  or   l
  ld   hl,0
  ret  nz
  dec  hl
  ret

; **** 2/ macro ****
definition_32_2f_macro:
 db end_definition_32_2f_macro-definition_32_2f_macro-1
  sra  h
  rr   l
end_definition_32_2f_macro:

; **** a>r macro ****
definition_61_3e_72_macro:
 db end_definition_61_3e_72_macro-definition_61_3e_72_macro-1
 push  hl
end_definition_61_3e_72_macro:

; **** b>r macro ****
definition_62_3e_72_macro:
 db end_definition_62_3e_72_macro-definition_62_3e_72_macro-1
 push  de
end_definition_62_3e_72_macro:

; **** c>r macro ****
definition_63_3e_72_macro:
 db end_definition_63_3e_72_macro-definition_63_3e_72_macro-1
 push  ix
end_definition_63_3e_72_macro:

; **** ab>r macro ****
definition_61_62_3e_72_macro:
 db end_definition_61_62_3e_72_macro-definition_61_62_3e_72_macro-1
 push  hl
 push  de
end_definition_61_62_3e_72_macro:

; **** abc>r macro ****
definition_61_62_63_3e_72_macro:
 db end_definition_61_62_63_3e_72_macro-definition_61_62_63_3e_72_macro-1
 push  hl
 push  de
 push  ix
end_definition_61_62_63_3e_72_macro:

; **** r>a macro ****
definition_72_3e_61_macro:
 db end_definition_72_3e_61_macro-definition_72_3e_61_macro-1
 pop  hl
end_definition_72_3e_61_macro:

; **** r>b macro ****
definition_72_3e_62_macro:
 db end_definition_72_3e_62_macro-definition_72_3e_62_macro-1
 pop  de
end_definition_72_3e_62_macro:

; **** r>c macro ****
definition_72_3e_63_macro:
 db end_definition_72_3e_63_macro-definition_72_3e_63_macro-1
 pop  ix
end_definition_72_3e_63_macro:

; **** r>ab macro ****
definition_72_3e_61_62_macro:
 db end_definition_72_3e_61_62_macro-definition_72_3e_61_62_macro-1
 pop  de
 pop  hl
end_definition_72_3e_61_62_macro:

; **** r>abc macro ****
definition_72_3e_61_62_63_macro:
 db end_definition_72_3e_61_62_63_macro-definition_72_3e_61_62_63_macro-1
 pop  ix
 pop  de
 pop  hl
end_definition_72_3e_61_62_63_macro:

; **** c! macro ****
definition_63_21_macro:
 db end_definition_63_21_macro-definition_63_21_macro-1
  ld   (hl),e
end_definition_63_21_macro:

; **** ! macro ****
definition_21_macro:
 db end_definition_21_macro-definition_21_macro-1
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
end_definition_21_macro:

; **** c@ macro ****
definition_63_40_macro:
 db end_definition_63_40_macro-definition_63_40_macro-1
  ld   l,(hl)
  ld   h,0
end_definition_63_40_macro:

; **** @ macro ****
definition_40_macro:
 db end_definition_40_macro-definition_40_macro-1
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
end_definition_40_macro:

; **** clr.screen word ****
definition_63_6c_72_2e_73_63_72_65_65_6e:
  jp   IOClearScreen

; **** cursor! word ****
definition_63_75_72_73_6f_72_21:
  jp   IOSetCursor

; **** debug word ****
definition_64_65_62_75_67:
  jp   DebugCode

; **** input@ word ****
definition_69_6e_70_75_74_40:
  ex   de,hl
  ld   hl,$0000
  ld   bc,$EFFE
  in   a,(c)
  bit  0,a
  jr   nz,__XInput0
  set  4,l
__XInput0:
  bit  4,a
  jr   nz,__XInput1
  set  2,l
__XInput1:
  bit  3,a
  jr   nz,__XInput2
  set  3,l
__XInput2:
  bit  2,a
  jr   nz,__XInput3
  set  0,l
__XInput3:
  ld   bc,$F7FE
  in   a,(c)
  bit  4,a
  jr   nz,__XInput4
  set  1,l
__XInput4:
  ret

; **** screen! word ****
definition_73_63_72_65_65_6e_21:
  ld   a,e
  jp   IOWriteCharacter

; **** halt word ****
definition_68_61_6c_74:
HaltSystem:
  di
__halt1:
  halt
  jr   __halt1

; **** port@ word ****
definition_70_6f_72_74_40:
  ld   b,h
  ld   c,l
  in   l,(c)
  ld   h,0
  ret

; **** port! macro ****
definition_70_6f_72_74_21_macro:
 db end_definition_70_6f_72_74_21_macro-definition_70_6f_72_74_21_macro-1
  ld   b,h
  ld   c,l
  out  (c),e
end_definition_70_6f_72_74_21_macro:

; **** a>b macro ****
definition_61_3e_62_macro:
 db end_definition_61_3e_62_macro-definition_61_3e_62_macro-1
  ld   d,h
  ld  e,l
end_definition_61_3e_62_macro:

; **** a>c macro ****
definition_61_3e_63_macro:
 db end_definition_61_3e_63_macro-definition_61_3e_63_macro-1
  push  hl
  pop  ix
end_definition_61_3e_63_macro:

; **** b>a macro ****
definition_62_3e_61_macro:
 db end_definition_62_3e_61_macro-definition_62_3e_61_macro-1
  ld   h,d
  ld  l,e
end_definition_62_3e_61_macro:

; **** b>c macro ****
definition_62_3e_63_macro:
 db end_definition_62_3e_63_macro-definition_62_3e_63_macro-1
  ld   ixh,d
  ld  ixl,e
end_definition_62_3e_63_macro:

; **** c>a macro ****
definition_63_3e_61_macro:
 db end_definition_63_3e_61_macro-definition_63_3e_61_macro-1
  push  ix
  pop  hl
end_definition_63_3e_61_macro:

; **** c>b macro ****
definition_63_3e_62_macro:
 db end_definition_63_3e_62_macro-definition_63_3e_62_macro-1
  ld   d,ixh
  ld  e,ixl
end_definition_63_3e_62_macro:

; **** swap macro ****
definition_73_77_61_70_macro:
 db end_definition_73_77_61_70_macro-definition_73_77_61_70_macro-1
  ex   de,hl
end_definition_73_77_61_70_macro:

; **** validate word ****
definition_76_61_6c_69_64_61_74_65:
  ex   de,hl
  ld   a,h
  cp   d
  jr   nz,__validate_fail
  ld   a,l
  cp   e
  jr   nz,__validate_fail
  jp   IOPrintHex
__validate_fail:
  call  DebugCode
  jp   HaltSystem

; **** sys.info macro ****
definition_73_79_73_2e_69_6e_66_6f_macro:
 db end_definition_73_79_73_2e_69_6e_66_6f_macro-definition_73_79_73_2e_69_6e_66_6f_macro-1
  ex   de,hl
  ld   hl,SystemInformation
end_definition_73_79_73_2e_69_6e_66_6f_macro:

; **** wordsize* macro ****
definition_77_6f_72_64_73_69_7a_65_2a_macro:
 db end_definition_77_6f_72_64_73_69_7a_65_2a_macro-definition_77_6f_72_64_73_69_7a_65_2a_macro-1
  add  hl,hl
end_definition_77_6f_72_64_73_69_7a_65_2a_macro:
