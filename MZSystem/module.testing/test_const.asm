; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_const.asm
;		Purpose : 	Test Constant conversion code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000
		db 		$DD,$01
		ld 		sp,$7F00

		ld 		hl,wd1
		call 	CONSTConvert
		ld 		hl,wd2
		call 	CONSTConvert
		ld 		hl,wd3
		call 	CONSTConvert
		ld 		hl,wd4
		call 	CONSTConvert

w1:		inc 	a
		and 	7
		out 	($FE),a
		jr 		w1

wd1:	db 		"42",0
wd2:	db 		"769",0
wd3:	db 		"32769",0
wd4:	db 		"2X",0

		include "..\files\library.asm"
