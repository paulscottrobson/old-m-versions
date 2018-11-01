; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		system.asm
;		Purpose:	Base file for M8 Core
;		Date:		11th August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

		opt 	zxnext
		org 	$5B00
		ld 		sp,(SIStack)						; set up stack.
		call 	IOClearScreen 						; clear screen
		ld 		hl,(SIRuntimeAddress)				; this is where you run from (initially Halt code)
		jp 		(hl)								; go there

		org 	$5C00 								; allow space for the stack
Z80Stack:		

		include "asm/slow.asm"						; macro code.
		include "asm/hardware.asm"					; console routines
		include "asm/compiler.asm"					; inline compiler stuff
		include "asm/errors.asm" 					; error handlers.

DictionaryBase:										; dictionary goes here, initially empty.
DictionarySpace:
		db 		0

		org 	$8000 								; program space.
		include "asm/multiply.asm"					; arithmetic routines
		include "asm/divide.asm"
		include "asm/fast.asm"						; built in words

ProgramSpace:										; free program memory

