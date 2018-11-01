; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		21st October 2018
;		Purpose :	ZForth Kernel
;
; ***************************************************************************************
; ***************************************************************************************

			org 	$8000
			jr 		Boot
			org 	$8004
			dw 		SystemInformation

Boot:		
			ld 		sp,(SIStack)					; reset Z80 Stack
			db 		$ED,$91,7,2						; set turbo port (7) to 2 (14Mhz)
			call	IOClearScreen					; clear screen and home cursor.
			call 	PAGEReset 						; switch to boot page.
			ld 		hl,(SIBootAddress)				; jump to boot address
			jp 		(hl)

HaltZ80:	di 										; stop the Z80 running.
			halt
			jr 		HaltZ80

ErrorHandlerHL:
			ld 		b,3
			call 	IOPrintString
EHHalt:		jr 		EHHalt	

			include "temp/include.asm"				; file built from kernel components
			include "data.asm"						; data allocation.
