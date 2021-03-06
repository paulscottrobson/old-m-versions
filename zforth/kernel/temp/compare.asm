; *********************************************************************************
; *********************************************************************************
;
;		File:		compare.asm
;		Purpose:	Comparison routines.
;		Created : 	29th October 2018
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;									= Test
;
; *********************************************************************************

__zfdefine_3d:
; @word =

	ld 		a,h
	cp 		d
	jr 		nz,__COMFalse
	ld 		a,l
	cp 		e
	jr 		nz,__COMFalse
__COMTrue:
	ld 		hl,$FFFF
	ret
__COMFalse:
	ld 		hl,$0000
	ret

; *********************************************************************************
;
;									<> Test
;
; *********************************************************************************

__zfdefine_3c_3e:
; @word <>

	ld 		a,h
	cp 		d
	jr 		nz,__COMTrue
	ld 		a,l
	cp 		e
	jr 		nz,__COMTrue
	jr 		__COMFalse

; *********************************************************************************
;
;									<= Test
;
; *********************************************************************************

__zfdefine_3c_3d:
; @word <=

	ld 		a,h
    xor 	d
    jp 		m,__LessEqual
    sbc 	hl,de
    jr 		nc,__COMTrue
    jr 		__COMFalse
__LessEqual:
	bit 	7,d
    jr 		z,__COMFalse
    jr 		__COMTrue

; *********************************************************************************
;
;
;
; *********************************************************************************

__zfdefine_3e:
; @word >

	ld 		a,h
    xor 	d
    jp 		m,__Greater
    sbc 	hl,de
    jr 		c,__COMTrue
    jr 		__COMFalse
__Greater:
	bit 	7,d
    jr 		nz,__COMFalse
    jr 		__COMTrue

