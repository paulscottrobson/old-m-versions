; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		test_paging.asm
;		Purpose : 	Test Paging code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000

		db 		$DD,$01
		ld 		sp,$7F00
		call 	PAGEReset

		ld 		a,$30
		call 	PAGESwitch
		ld		a,$34
		call 	PAGESwitch
		call 	PAGERestore
		call 	PAGERestore	

w1:		jr 		w1

		include "..\files\library.asm"
