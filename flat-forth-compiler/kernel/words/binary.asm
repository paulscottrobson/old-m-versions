; *********************************************************************************
; *********************************************************************************
;
;		File:		binary.asm
;		Purpose:	Binary words
;		Created : 	29th October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;									Add B into A
;
; *********************************************************************************

; @macro +
		add 	hl,de
; @endm

; *********************************************************************************
;
;								Subtract A from B => B
;
; *********************************************************************************

; @macro -
		ex		de,hl
		ld 		b,d
		ld 		c,e
		xor 	a
		sbc 	hl,de
; @endm

; *********************************************************************************
;
;									And B into A
;
; *********************************************************************************

; @word and
		ld 		a,h
		and 	d
		ld 		h,a
		ld 		a,l
		and 	e
		ld 		l,a
		ret

; *********************************************************************************
;
;									Or B into A
;
; *********************************************************************************

; @word or
		ld 		a,h
		or 	 	d
		ld 		h,a
		ld 		a,l
		or  	e
		ld 		l,a
		ret

; *********************************************************************************
;
;									Xor B into A
;
; *********************************************************************************

; @word xor
		ld 		a,h
		xor 	d
		ld 		h,a
		ld 		a,l
		xor 	e
		ld 		l,a
		ret
