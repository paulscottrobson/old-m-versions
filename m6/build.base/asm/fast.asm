;
;		automatically generated
;
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

; ******** abs ********
define_61_62_73_word:
  bit  7,h
  ret  z
  jr   __Negate
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

