; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		system.asm
;		Purpose:	Base file for M6 Core
;		Date:		15th August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

		opt 	zxNext
		org 	$5B00
		ld 		sp,(SIStack)						; set up stack.
		call 	IOClearScreen 						; clear screen
		ld 		hl,(SIRuntimeAddress)				; this is where you run from (initially Halt code)
		jp 		(hl)								; go there

		org 	$5C00								; allow space for the stack
Z80Stack:		
		include "asm/hardware.asm"					; console routines

editBufferSize = 512
		db 		0,0,0,0								; buffer for editing etc, with some boundary space.
EditBuffer:
		ds 		editBufferSize
		db 		0,0,0,0

DictionaryStart:
		db 		0									; dictionary goes here.

		org 	$8000 								; program space.
		include "asm/multiply.asm"					; arithmetic routines
		include "asm/divide.asm"			
		include "asm/corewords.asm"					; built in words
ProgramSpace:										; free program memory

