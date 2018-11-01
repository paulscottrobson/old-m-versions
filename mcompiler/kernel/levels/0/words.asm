; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		words.asm
;		Purpose : 	word definitions (level 0)
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	17th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;											.h
; ***********************************************************************************************
;;	Primarily used for debugging, .h outputs register A as a 4 digit hexadecimal number prefixed
;;  by a space. Location is system specific, but a sequence of them should show as a sequence on
;;  the display. 

; @word .h
		jp 		IOPrintHex
		
; ***********************************************************************************************
;											Add B into A
; ***********************************************************************************************
;;	Add the contents of register B into register A, leaving register B unchanged.

; @macro +
		add 	hl,de
; @endmacro

; ***********************************************************************************************
;											Nand B into A
; ***********************************************************************************************
;; 	Calculate the binary NAND of registers A and B, putting the result into A. NAND is the one's
;;  complement of binary AND, and is used mostly as a constructor for other operations.

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

; ***********************************************************************************************
; 								Return true if A < 0, false otherwise
; ***********************************************************************************************
;;	Sets A to ($FFFF) True if A is negative (e.g. bit 15 is set), and False ($0000) if positive
;;  or zero.

; @word 0<
		bit 	7,h
		ld 		hl,0
		ret 	z
		dec 	hl
		ret

; ***********************************************************************************************
; 								Return true if A == 0, false otherwise
; ***********************************************************************************************
;;	Sets A to ($FFFF) True if A is zero, and False ($0000) if A is non-zero

; @word 0=
		ld 		a,h
		or 		l
		ld 		hl,0
		ret 	nz
		dec 	hl
		ret

; ***********************************************************************************************
; 								Divide by 2
; ***********************************************************************************************
;; Arithmetic shift right of A, preserving the sign bit.

; @macro 2/
		sra 	h
		rr 		l
; @endmacro
	
; ***********************************************************************************************
;										Register to/from Stack
; ***********************************************************************************************

;; Push A onto the return stack
; @macro a>r
	push 	hl	
; @endmacro

;; Push B onto the return stack
; @macro b>r
	push 	de
; @endmacro

;; Push C onto the return stack
; @macro c>r
	push 	ix
; @endmacro

;; Push A and B onto the return stack
; @macro ab>r
	push 	hl
	push 	de
; @endmacro

;; Push A,B and C onto the return stack
; @macro abc>r
	push 	hl
	push 	de
	push 	ix
; @endmacro

;; Pop A off the return stack
; @macro r>a
	pop 	hl
; @endmacro

;; Pop B off the return stack
; @macro r>b
	pop 	de
; @endmacro

;; Pop C off the return stack
; @macro r>c
	pop 	ix
; @endmacro

;; Pop B and A off the return stack
; @macro r>ab
	pop 	de
	pop 	hl
; @endmacro

;; Pop C,B and A off the return stack
; @macro r>abc
	pop 	ix
	pop 	de
	pop 	hl
; @endmacro

; ***********************************************************************************************
;										Write Memory
; ***********************************************************************************************

;;	Save B at memory location A, writing a single byte
; @macro c! 
		ld 		(hl),e
; @endmacro

;;	Save B at memory location A, writing a word.
; @macro !
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		dec 	hl
; @endmacro

; ***********************************************************************************************
;										Read Memory
; ***********************************************************************************************

;; Read a single byte from A into A
; @macro c@ 
		ld 		l,(hl)
		ld 		h,0
; @endmacro

;; Read a single word from A into A
; @macro @
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a
; @endmacro

; ***********************************************************************************************
;									Simple I/O Functionality
; ***********************************************************************************************

;; Clear the display
; @word clr.screen
		jp 		IOClearScreen

;; Sets the cursor position to A, where A is a character offset from the top of the screen
;; The screen dimensions are in the sys.info table
; @word cursor!
		jp 		IOSetCursor

;; Update the debug display ABC on the screen, by convention this is usually at the bottom
;; right of the screen.
; @word debug
		jp 		DebugCode

;; Scan the keyboard returning a "Joystick" input.  The lower 5 bits represent Fire, Up, 
;; Down, Left and Right respectively (Bit 0 = Right). Other bits are at present zero but
;; this should not be assumed. This is equivalent to the Kempston Joystick format.
;; This copies A into B first as load and constants do.
;; The equivalent keys are 5 (left) 6 (down) 7 (up) 8 (right) 0 (fire) on a Spectrum.

; @word input@
		ex 		de,hl
		ld 		hl,$0000
		ld 		bc,$EFFE
		in 		a,(c)
		bit 	0,a
		jr 		nz,__XInput0
		set 	4,l
__XInput0:
		bit 	4,a
		jr 		nz,__XInput1
		set 	2,l
__XInput1:
		bit 	3,a
		jr 		nz,__XInput2
		set 	3,l
__XInput2:
		bit 	2,a
		jr 		nz,__XInput3
		set 	0,l
__XInput3:
		ld 		bc,$F7FE
		in 		a,(c)
		bit 	4,a
		jr 		nz,__XInput4
		set 	1,l
__XInput4:
		ret

;# F(0) U D L R (LDUR Speccy)

;; Write character B (2+6 format) to A where A is a character offset from the top of the screen
;; The screen dimensions are in the sys.info table
; @word screen!
		ld 		a,e
		jp 		IOWriteCharacter

; ***********************************************************************************************
;											Halt program
; ***********************************************************************************************
;; Stop the program running.
; @word halt

HaltSystem:
		di
__halt1:	
		halt
		jr 		__halt1

; ***********************************************************************************************
;										Port Read/Write
; ***********************************************************************************************
;; Read port A into A. This is an 8 bit read, but a full port address (e.g. 16 bits)
; @word port@ 
		ld 		b,h
		ld 		c,l
		in 		l,(c)
		ld 		h,0
		ret

;; Write B into port A. This is an 8 bit write, but A represents a full port address of 16 bits
; @macro port!
		ld 		b,h
		ld 		c,l
		out 	(c),e
; @endmacro

; ***********************************************************************************************
;									Register to Register copying
; ***********************************************************************************************
;; Copy Register A to Register B
; @macro a>b
		ld 		d,h
		ld		e,l
; @endmacro

;; Copy Register A to Register C
; @macro a>c
		push 	hl
		pop 	ix
; @endmacro

;; Copy Register B to Register A
; @macro b>a
		ld 		h,d
		ld		l,e
; @endmacro

;; Copy Register B to Register C
; @macro b>c
		ld 		ixh,d
		ld		ixl,e
; @endmacro

;; Copy Register C to Register A
; @macro c>a
		push 	ix
		pop 	hl
; @endmacro

;; Copy Register C to Register B
; @macro c>b
		ld 		d,ixh
		ld		e,ixl
; @endmacro

; ***********************************************************************************************
;										Swap A & B
; ***********************************************************************************************
;; Exchange A and B
; @macro swap
		ex 		de,hl
; @endmacro

; ***********************************************************************************************
;										Check A = B
; ***********************************************************************************************
;; If A != B then swap them, debug display and halt. This is used for validity check code, so 
;; you would do a calculation into A and put what it should be into B ; if it fails it displays
;; A (answer got) B (answer required) and C as an error.
;; If the result passes swap them and print the result (the returned answer)

; @word validate
		ex 		de,hl
		ld 		a,h
		cp 		d
		jr 		nz,__validate_fail
		ld 		a,l
		cp 		e
		jr 		nz,__validate_fail
		jp 		IOPrintHex
__validate_fail:
		call 	DebugCode
		jp 		HaltSystem

; ***********************************************************************************************
;							  Put system info address into A
; ***********************************************************************************************
;; Put the address of the system information table in A
;; This copies A into B first as load and constants do.
; @macro sys.info
		ex 		de,hl
		ld 		hl,SystemInformation
; @endmacro

; ***********************************************************************************************
;							Scale a word count to a byte size
; ***********************************************************************************************
;; Converts a word count to a byte size, so for a Spectrum this is x2 , but for an Amiga
;; (68000 CPU) it would be x4.
; @macro wordsize*
		add 	hl,hl
; @endmacro
