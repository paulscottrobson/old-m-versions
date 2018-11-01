; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_compiler.asm
;		Purpose : 	Test Constant conversion code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000
		;db 		$DD,$01
		ld 		sp,$7F00
		call 	PAGEReset

		ld 		hl,wd1
		call 	DICTAddWord
		ld 		a,1
		call 	DICTOrInformationByte
		ld 		hl,SICodeFree
		inc 	(hl)

		ld 		hl,wd2
		call 	DICTAddWord
		ld 		hl,SICodeFree
		inc 	(hl)

		ld 		hl,wd4
		call 	DICTAddWord
		ld 		a,0
		call 	DICTOrInformationByte

		db 		$DD,$01
		ld 		hl,wd3
		call 	CompileTest
		ld 		hl,wd1
		call 	CompileTest
		ld 		hl,wd2
		call 	CompileTest
		ld 		hl,wd4
		call 	CompileTest
		ld 		hl,wd5
		call 	CompileTest

w1:		inc 	a
		and 	7
		out 	($FE),a
		jr 		w1

wd1:	db 		"TEST42",0
wd2:	db 		"DEMO769",0
wd3:	db 		"32769",0
wd4:	db 		"FARMAC",0
wd5:	db 		"X2X",0

CompileTest:
		ld 		a,' '
		call 	IOPrintCharacter
		call 	IOPrintASCIIZString
		ld 		a,':'
		call 	IOPrintCharacter
		ld 		de,$A000
		ld 		(SICodeFree),de
		call 	COMCompile
		ret 	c
		ld 		hl,$A000
		ld 		a,(SICodeFree)
		or 		a
		ret 	z
		ld 		b,a
__CTDisplay:
		ld 		a,(hl)
		call 	IOPrintHexByte
		ld 		a,' '
		call 	IOPrintCharacter
		inc 	hl
		djnz 	__CTDisplay
		ret

		include "..\files\library.asm"
