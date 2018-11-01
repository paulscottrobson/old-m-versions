;
;		automatically generated
;
; ******** and ********
define_word_61_6e_64:
  ld   a,h
  and  d
  ld   h,a
  ld   a,l
  and  e
  ld   l,a
  ret

; ---------------------------------------------

; ******** max ********
define_word_6d_61_78:
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
define_word_6d_69_6e:
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
define_word_6d_6f_64:
  push   de
  call   DivideMod16
  pop   de
  ret

; ---------------------------------------------

; ******** or ********
define_word_6f_72:
  ld   a,h
  or   d
  ld   h,a
  ld   a,l
  or   e
  ld   l,a
  ret

; ---------------------------------------------

; ******** / ********
define_word_2f:
  push   de
  call   DivideMod16
  ex    de,hl
  pop   de
  ret

; ---------------------------------------------

; ******** = ********
define_word_3d:
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
  ld   hl,$0000
  ret

; ---------------------------------------------

; ******** > ********
define_word_3e:
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
define_word_3e_3d:
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
define_word_3c:
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
define_word_3c_3d:
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
define_word_3c_3e:
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
define_word_78_6f_72:
  ld   a,h
  xor  d
  ld   h,a
  ld   a,l
  xor  e
  ld   l,a
  ret

; ---------------------------------------------

; ******** -! ********
define_word_2d_21:
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
define_word_2b_21:
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
define_word_63_6f_70_79:
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
define_word_66_69_6c_6c:
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
define_word_30_3d:
  ld   a,h
  or   l
  ld   hl,$0000
  ret  nz
  dec  hl
  ret

; ---------------------------------------------

; ******** 0< ********
define_word_30_3c:
  bit  7,h
  ld   hl,$0000
  ret  z
  dec  hl
  ret

; ---------------------------------------------

; ******** 0- ********
define_word_30_2d:
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
define_word_61_62_73:
  bit  7,h
  ret  z
  jr   __Negate
  ret

; ---------------------------------------------

; ******** not ********
define_word_6e_6f_74:
  ld   a,h
  cpl
  ld   h,a
  ld   a,l
  cpl
  ld  l,a
  ret

; ---------------------------------------------

