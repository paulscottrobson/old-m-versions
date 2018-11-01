; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		core.asm
;		Purpose : 	Core words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	6th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; @macro ;
		ret
; @endm

; @macro +
		add 	hl,de
; @endm

; @word .h
		ld 		a,' '
		call 	IOPrintCharacter
		jp 		IOPrintHexWord

; @word 0<
		bit 	7,h
		ld 		hl,0
		ret 	z
		dec 	hl
		ret

; @word 0=
		ld 		a,h
		or 		l
		ld 		hl,0
		ret 	nz
		dec 	hl
		ret

; @word <
		ld 		a,h
        xor 	d
        jp 		m,__LessSignsDifferent
        push 	de
        ex 		de,hl
        sbc 	hl,de     
        pop 	de
        jr 		c,__LessTrue
__LessFalse:
        ld 		hl,$0000
        ret
__LessSignsDifferent:     
		bit 	7,d
        jr 		z,__LessFalse
__LessTrue:
        ld 		hl,$FFFF
        ret
; @macro 2/
		sra 	h
		rr 		l
; @endm

; @macro ab>r 
		push 	de
		push 	hl
; @endm

; @macro r>ab
		pop 	hl
		pop 	de
; @endm

; @macro a>r 
		push 	hl
; @endm

; @macro b>r
		push 	de
; @endm

; @macro r>a 
		pop 	hl
; @endm

; @macro r>b
		pop 	de
; @endm

; @macro c! 
		ld 		(hl),e
; @endm

; @macro !
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		dec 	hl
; @endm

; @macro c@ 
		ld 		l,(hl)
		ld 		h,0
; @endm

; @macro @
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a
; @endm

; @word clr.screen
		jp 		IOClearScreen

; @word cursor!
		jp 		IOSetCursor

; @word debug
		jp 		DebugCode

; @word halt
		jp 		HaltCode

; @word inkey
		call	IOScanKeyboard
		ex 		de,hl
		ld 		l,a
		ld 		h,0
		ret

; @word nand
		ld 		a,h
		and 	d
		cpl 	
		ld 		h,a
		ld 		a,l
		and 	e
		cpl 	
		ld 		l,a
		ret

; @word port@ 
		ld 		b,h
		ld 		c,l
		in 		l,(c)
		ld 		h,0

; @word port!
		ld 		b,h
		ld 		c,l
		out 	(c),e

; @macro a>b 
		ld 		d,h
		ld		e,l		
; @endm

; @macro b>a
		ld 		h,d
		ld		l,e
; @endm

; @word screen!
		ld 		a,e
		jp 		IOWriteCharacter

; @macro swap
		ex 		de,hl
; @endm

; @word sys.info
		ex 		de,hl
		ld 		hl,SystemInformation
		ret

; @word validate
		ex 		de,hl
		ld 		a,h
		cp 		d
		jr 		nz,__validate_fail
		ld 		a,l
		cp 		e
		jr 		nz,__validate_fail
		ld 		a,' '
		call	IOPrintCharacter
		jp 		IOPrintHexWord
__validate_fail:
		call 	DebugCode
		jp 		HaltCode

; @macro wordsize*
		add 	hl,hl
; @endm

; @word *
		jp	 	MULTMultiply16

; @word /
		push 	de
		call 	DIVDivideMod16
		ex 		de,hl
		pop 	de
		ret

; @word mod
		push 	de
		call 	DIVDivideMod16
		pop 	de
		ret
