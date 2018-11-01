; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		system.asm
;		Purpose:	Base file for M9 Core
;		Date:		11th August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

		org 	$5B00
		ld 		sp,(SIStack)						; set up stack.
		call 	IOClearScreen 						; clear screen
		ld 		hl,(SIRunTimeAddress)				; this is where you run from (initially Halt code)
		jp 		(hl)								; go there

		org 	$5C00 								; allow space for the stack
Z80Stack:		

		include "asm/slow.asm"						; macro code.
		include "asm/hardware.asm"					; console routines

HighSlowMemory:

		org 	$8000 								; program space.
		include "asm/multiply.asm"					; arithmetic routines
		include "asm/divide.asm"
		include "asm/fast.asm"						; built in words

HighFastMemory: