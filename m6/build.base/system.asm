; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		system.asm
;		Purpose:	Base file for M6 Core
;		Date:		23rd August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

		opt 	zxNext
		org 	$5B00
SIALoadAddress:
		ld 		sp,(SIAStack)						; set up stack.
		call 	IOClearScreen 						; clear screen
		ld 		hl,(SIARuntimeAddress)				; this is where you run from (initially Halt code)
		jp 		(hl)								; go there

		org 	$5C00								; allow space for the stack
Z80Stack:		
		include "asm/hardware.asm"					; console routines
		include "asm/slow.asm"

editBufferSize = 512 								; buffer with padding.
		db 		0,0,0,0
editBuffer:
		ds 		editBufferSize
		db 		0,0,0,0

DictionaryBase:										; dictionary will go here.
		db 		0

		org 	$8000 								; program space.
DictionaryEnd:
		include "asm/multiply.asm"					; arithmetic routines
		include "asm/divide.asm"			
		include "asm/fast.asm"						; built in words

ProgramSpace:										; free program memory
