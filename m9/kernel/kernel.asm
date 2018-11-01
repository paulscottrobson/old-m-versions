; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		kernel.asm
;		Purpose : 	Kernel
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	17th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 		zxNext
		org 		$5B00
ColdStart:		
		jr 			Boot

SystemInformation:
		dw 			ColdStart					; +0,+1 	Cold Start/Load Address
		dw 			FreeMemory					; +2,+3 	Free Data (if seperate)
		dw			$8000 						; +4,+5 	Free Code Memory address
		db 			0 							; +6 		Free Code Page address
		db 			0							; +7 		Paging system (standard)
		dw 			0 							; +8,+9 	Dictionary Base (not used)
MainAddress:
		dw 			HaltSystem 					; +10,+11 	Main address (fixed to stop)
		db 			IOScreenWidth				; +12 		Screen Width
		db 			IOScreenHeight 				; +13 		Screen Height
StackReset:
		dw 			StackTop 					; +6,+7 Stack rese

Boot:	db 			$DD,$01
		di 										; interrupt off
		ld 			sp,(StackReset)				; default stack
		ld			hl,(MainAddress) 			; push start address on stack
		push 		hl
		ld 			hl,$0000					; reset registers
		ld 			de,$0000
		ld 			bc,$0000
		ret 									; and go to the start

		include 	"support/multiply.asm" 		; support files
		include 	"support/divide.asm"
		include 	"support/hardware.asm"
		include 	"support/debug.asm"

		include 	"temp/__words.asm"			; constructed file.

		ds 			128
StackTop:
		dw 			0

FreeMemory:
