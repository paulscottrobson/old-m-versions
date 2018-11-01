; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_process.asm
;		Purpose : 	Test Process code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000

		ld 		sp,$7F00
		ld 		de,testStart
		ld 		hl,testEnd
		call 	PARSESetBuffer
tpLoop:
		call 	PARSENextWord
		jr 		c,w1
		call	IOPrintASCIIZString
		ld 		a,':'
		call 	IOPrintCharacter
		push 	hl
		ld 		l,e
		ld 		h,0
		call 	IOPrintHexWord
		pop 	hl
		ld 		a,' '
		call 	IOPrintCharacter
		call	PROCProcessWord
		jr 		tpLoop

w1:		inc 	a
		and 	7
		out 	($FE),a
		jr 		w1

testStart:		
		db 		'T' & $3F,"EST1 "
		db 		'4'+$80,"2 "
		db 		'T'+$40,"EST1 "
		db 		'2'+$C0,"01 "
		db 		'T'+$80,"EST1 "
testEnd:

		include "..\files\library.asm"

