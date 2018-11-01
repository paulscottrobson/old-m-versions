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
		org 		$8000
		jr 			Boot

		org 		$8004
SystemInformation:
		dw			FreeCodeMemory				; +0,+1 	Free Code Memory address
		db 			0x00						; +2 		Free Code Page address
MainAddress:
		dw 			HaltSystem 					; +3,+4 	Main address (fixed to stop)
StackReset:
		dw 			StackTop 					; +5,+6		Stack reset address

Boot:	;db 			$DD,$01
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

FreeCodeMemory: