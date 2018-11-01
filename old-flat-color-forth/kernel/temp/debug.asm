; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		debug.asm
;		Purpose : 	Debug routine (shows A B on bottom line)
;		Created : 	21st October 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

__cfdefine_64_65_62_75_67:
; @forth debug
;; display the status of the A and B registers on the bottom line, as a debugging aid.

DebugCode:
		push 	bc
		push 	de
		push 	hl

		push 	de
		push 	hl

		ld 		a,(SIScreenWidth)					; move 13 in from left
		sub 	13
		ld 		l,a
		ld 		a,(SIScreenHeight)					; on the bottom line
		dec 	a
		ld 		h,a
		call 	IOSetCursor

		pop 	de 									; display A
		ld 		c,'A'
		call 	__DisplayHexInteger

		ld 		a,' '
		call 	IOPrintChar

		pop 	de 									; display B
		ld 		c,'B'
		call 	__DisplayHexInteger

		pop 	hl
		pop 	de
		pop 	bc
		ret

__DisplayHexInteger:
		ld 		a,5
		call 	IOSetColour
		ld 		a,c
		call 	IOPrintChar
		inc 	hl
		ld 		a,7
		call 	IOSetColour
		ld 		a,':'
		call 	IOPrintChar
		inc 	hl
		ex 		de,hl
		ld 		a,4
		call 	IOSetColour
		call 	IOPrintHexWord
		ex 		de,hl
		ret
