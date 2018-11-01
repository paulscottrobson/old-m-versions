; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		kernel.asm
;		Purpose : 	Kernel
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	29th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

;
;		These are all pairs of 8k pages.
;
DictionaryPage = $20 							; page containing dictionary
FirstTextPage = $22 							; first page containing booting code
LastTextPage = $22 								; last page containing booting code
FirstCodePage = $24 							; code starts here (pages in pairs)
LastCodePage = $4E 								; last available page of code

		opt 		zxNextReg
		org 		$8000
		jr 			Boot
		org 		$8004

; ***********************************************************************************************
;
;									System Information Area
;
; ***********************************************************************************************

CodeAddress:
		dw			FreeCodeMemory				; +0,+1 	Free Code Memory address
CodePage:
		db 			FirstCodePage				; +2 		Free Code Page address
MainAddress:
		dw 			LoadCode 					; +3,+4 	Main address (fixed to stop)
MainCodePage:
		db 			FirstCodePage 				; +5 		Page this is on.
StackReset:
		dw 			StackTop 					; +6,+7		Stack reset address
DictionaryFree:
		dw 			$C000 						; +8,+9 	Next free dictionary byte.		

; ***********************************************************************************************
;
;											Boot code.
;
; ***********************************************************************************************

Boot:	;db 		$DD,$01
		di 										; interrupt off
		nextreg 	7,2 						; switch to 14Mhz clock.
		call 		IOClearScreen
		ld 			a,(MainCodePage) 			; set current page
		call 		PAGESet
		ld 			sp,(StackReset)				; default stack
		ld			hl,(MainAddress) 			; push start address on stack
		push 		hl
		ld 			hl,$0000					; reset registers
		ld 			de,$0000
		ret 									; and go to the start
;
HaltSystem: 									; stop the CPU
		di 										; interrupts off
		halt  									; stop CPU
		jr 			HaltSystem 					; just in case :)

; ***********************************************************************************************
;
;									Component parts of system
;
; ***********************************************************************************************

		include		"compiler\parser.asm"
		include 	"compiler\dictionary.asm"
		include 	"compiler\word.asm"
		include  	"compiler\loader.asm"
		include 	"compiler\paging.asm"
		include 	"support\hardware.asm"
		include 	"support\multiply.asm"
		include 	"support\divide.asm"
		include 	"support\debug.asm"
		include 	"temp\words.asm"
		
; ***********************************************************************************************
;
;											 Data areas
;
; ***********************************************************************************************

		ds 			128 						; stack memory.
StackTop:
		dw 			0
ExecuteBuffer: 									; buffer for yellow execute words
		ds 			32
		dw 			0
EditBuffer:										; editing buffer 
		ds 			1024
		dw 			0

FreeCodeMemory:
