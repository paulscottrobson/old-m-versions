; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_parser.asm
;		Purpose : 	Test Parser code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000

		db 		$DD,$01
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
		ld 		l,e
		ld 		h,0
		call 	IOPrintHexWord
		ld 		a,' '
		call 	IOPrintCharacter
		jr 		tpLoop

w1:		inc 	a
		and 	7
		out 	($FE),a
		jr 		w1


testStart:
		db 		"   HELLO WORLD "
		db 		'R' & $3F,"ED "
		db 		" WHITE "
		db 		'G'+$40,"REEN "
		db 		'Y'+$80,"ELLOW "
testEnd:

		include "..\files\library.asm"
