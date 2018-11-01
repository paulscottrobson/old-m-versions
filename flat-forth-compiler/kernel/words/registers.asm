; *********************************************************************************
; *********************************************************************************
;
;		File:		register.asm
;		Purpose:	Register words
;		Created : 	29th October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;									Swap A+B
;
; *********************************************************************************

; @macro swap
		ex 		de,hl
; @endm

; *********************************************************************************
;
;									Copy A to B
;
; *********************************************************************************

; @macro a>b
		ld 		d,h
		ld 		e,l
; @endm

; *********************************************************************************
;
;									Copy B to A
;
; *********************************************************************************

; @macro b>a
		ld 		h,d
		ld 		l,e
; @endm

; *********************************************************************************
;
;									Register/Stack
;
; *********************************************************************************

; @macro ab>r
		push 	de
		push 	hl
; @endm

; @macro a>r
		push 	hl
; @endm

; @macro b>r
		push 	de
; @endm

; @macro r>ab
		pop 	hl
		pop 	de
; @endm

; @macro r>a
		pop 	hl
; @endm

; @macro r>b
		pop 	de
; @endm

