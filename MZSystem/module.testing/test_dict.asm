; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_dict.asm
;		Purpose : 	Test Dictionary code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000

		ld 		sp,$7F00

		ld 		hl,wd1
		call 	DICTAddWord

		ld 		hl,SICodeFree
		inc 	(hl)
		ld 		hl,wd2
		call 	DICTAddWord
		ld 		a,$82
		call 	DICTOrInformationByte

		ld 		hl,SICodeFree
		inc 	(hl)
		ld 		hl,wd3
		call 	DICTAddWord
		ld 		a,$01
		call 	DICTOrInformationByte

		db 		$DD,$01
		ld 		hl,wd4
		call 	DICTFindWord

		ld 		a,(SIDictionaryPage) 				; so we can look at it.
		call 	PAGESwitch
w1:		inc 	a
		and 	7
		out 	($FE),a
		jr 		w1

wd1:	db 		"DEMO",0
wd2:	db 		"COUNT",0
wd3:	db 		"TEST1",0
wd4:	db 		"TEST2",0

		include "..\files\library.asm"
