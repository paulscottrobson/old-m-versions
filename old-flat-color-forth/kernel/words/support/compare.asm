; *********************************************************************************
; *********************************************************************************
;
;		File:		compare.asm
;		Purpose:	Comparison routines.
;		Created : 	25th October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;									= Test
;
; *********************************************************************************

; @forth = 
;; return true if A = B in A, false otherwise.

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

; @forth <>
;; return true if A <> B in A, false otherwise.

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

; @forth <=
;; return true if B <= A in A, false otherwise
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

; @forth >
;; return true if B > A in A, false otherwise
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
