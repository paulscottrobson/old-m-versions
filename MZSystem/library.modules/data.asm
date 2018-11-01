; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		data.asm
;		Purpose : 	All Read/Write data in the library mdoules
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************


; ***********************************************************************************************
;
;									System Information Area
;
; ***********************************************************************************************

SystemInformation:

SIDictionaryPage:
		db 		$20,$00 							; +0		Dictionary page.
SIFirstCodePage:
		db 		$24,$00 							; +2 		First code page.
SIDictionaryFree: 
		dw 		$C000 								; +4,+5		Dictionary free pointer (in page)
SICodeFree:					
		dw 		FreeCodeMemory						; +6,+7 	Code free pointer
SICodePage:
		db 		$24,$00 							; +8 		Code free page
SIFirstBootstrapPage:
		db 		$22,$00 							; +10 		First bootstrap page
SILastBootstrapPage:
		db 		$22,$00 							; +12 		Last bootstrap page
SIStackTop:
		dw 		StackInitialValue 					; +14,+15 	Stack initial value
SIRunAddress:
		dw 		LoadCode 							; +16,+17 	Run address
SIRunPage: 										
		db 		$24 								; +18 		Run address page

; ***********************************************************************************************
;
;									Uninitialised Data area
;
; ***********************************************************************************************

PAGEStackPointer:									; paging undo stack pointer
		dw 		0
PAGEStack: 											; paging undo stack.
		dw 		0,0,0,0

PARSECurrent:										; next text to scan
		dw 		0
PARSEEnd: 											; end of text to scan
		dw 		0 
PARSEBuffer:										; buffer for parsed word
		ds 		64 									
PARSEWordType: 										; type of word read in to parse buffer.
		db 		0 									

IOCursorPosition: 									; cursor position in charactes
		dw 		0

DICTLastInformationByte:							; address of last information byte in last created dictionary word
		dw 		0

COM_ARegister: 										; registers used for direct execution.
		dw 		0
COM_BRegister:
		dw 		0

PROCExecBuffer:										; execution space for yellow words
		ds 		32

		dw 		0,0 								; main 1k edit buffer.
EditBuffer:
		ds 		1024
		dw 		0,0

		ds 		128
StackInitialValue:									; Z80 Stack Space
		dw 		0

DataTransferCount:									; used as the count for FILL and COPY which take three parameters
		dw 		0

		
FreeCodeMemory:
