; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		6th October 2018
;		Purpose :	MZ Cross Compiler Machine code kernel.
;
; ***************************************************************************************
; ***************************************************************************************

DictionaryPage = $20 								; Dictionary starts at this page
FirstCodePage = $22 								; Code Memory starts here
LastCodePage = $4E 									; Code Memory ends here

; ***************************************************************************************
;
;										Start up 
;
; ***************************************************************************************

		org 	$8000 								; enter at $8000
		jr 		Boot
		org 	$8004
		dw 		SystemInformation 					; address of SYSINFO at $8004
MacroExpansion:
		jr 		MacroExpansion 						; macro expansion at $8006


; ***************************************************************************************
;
;								Load and run boot code
;
; ***************************************************************************************

Boot:	;db 	$DD,$01
		di
		ld 		sp,(SIStackResetValue)				; reset the stack
		call 	PAGEReset 							; reset the paging system.
		call 	IOClearScreen
		ld 		hl,0
		call 	IOSetCursor
		ld 		a,(SIBootProgramPage)				; switch to the boot program page
		call 	PAGESwitch
		ld 		hl,(SIBootProgramAddress) 			; get address of boot program
		jp 		(hl)								; go there.

HaltCode: 											; pretty much giving up here.
		di
		halt
		jr 		HaltCode

; ***************************************************************************************
;
;								Words and Support Files
;
; ***************************************************************************************

		include "support/debug.asm"
		include "support/multiply.asm"
		include "support/divide.asm"
		include "support/hardware.asm"
		include "temp/words.asm"

; ***************************************************************************************
;
;								Data Area
;
; ***************************************************************************************

		include "support/data.asm"

; ***************************************************************************************
;
;								System Information Table
;
; ***************************************************************************************

SystemInformation:

SICodeFree:
		dw 		FreeMemory 							; +0,+1 		Address of next free code byte
SICodePageFree:
		db		FirstCodePage 						; +2 			Code Page of next free code byte
SIDictionaryPage:
		db 		DictionaryPage						; +3 			Code Page of dictionary
SIDictionaryFree:
		dw 		$C000 								; +4,+5 		Next free byte in dictionary
SIBootProgramAddress:
		dw		HaltCode 							; +6,+7 		Code to execute when starting
SIBootProgramPage:
		db 		FirstCodePage 						; +8 			Code page of startup program
SIStackResetValue:
		dw 		StackResetValue 					; +9,+10 		Initial Z80 Stack

		dw 		PageSwitchTable						; +11,+12 		Page Switch routine (for $20/1)
		db 		PageSwitchSecondElement-PageSwitchTable
													; +13 			Gap between each routine.
		ds		128
StackResetValue:
		dw 		0

DataTransferCount:									; count of bytes to fill/copy
		dw 		0
		
FreeMemory:

		org 	$C000 								; first switchable page, e.g. the dictionary
		db 		0 									; first dictionary offset.
		org 	$10000 								; make sure it's all there.
