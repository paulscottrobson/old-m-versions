; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		21st October 2018
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

EditBufferSize = 512

; ***************************************************************************************
;
;									System Information
;
; ***************************************************************************************

SystemInformation:

SICodeFree:			
		dw 		FreeMemory,0 						; +0  Next free byte for code/data
SIDictionaryFree:
		dw 		$C000,0 							; +4  Next free byte in dictionary
SIBootAddress:
		dw 		LOADBootstrap,0						; +8  Boot address
SIDictionaryPage:
		dw 		$20,0								; +12 Page Number of dictionary
SIBootstrapPage:	
		dw 		$22,0 								; +16 Page Number of bootstrap page
SICodeFreePage:
		dw 		$24,0 								; +20 Page Number, next free code.
SIBootPage:	
		dw 		$24,0 								; +24 Boot page
SIStack:
		dw 		StackTop,0							; +28 Initial stack value
SIFontBase:	
		dw 		AlternateFont,0						; +32 Base address of font (space)
SIScreenWidth:
		dw 		32,0 								; +36 Screen width, characters
SIScreenHeight:
		dw 		24,0 								; +40 Screen height, characters
SIScreenManager:
		dw 		ZX48KPrint,0 						; +44 Hardware Console Driver

; ***************************************************************************************
;
;								 Other data and buffers
;
; ***************************************************************************************

;
;		The edit buffer and stack are moved into memory not used by the LoRes mode.
;
EditBuffer = 	$7800 								; Editor Buffer

StackTop   = 	$7FFF 								; Top of stack


PAGEStackPointer:									; stack for PAGEswitch and restore
		dw 		0
PAGEStack:
		ds 		16

IOColour:											; screen colour
		db 		7
IOCursorX: 											; position on screen.
		db 		0
IOCursorY:
		db 		0

PARSEPointer: 										; next character to parse.
		dw 		0
PARSEBuffer: 										; buffer for parsed word.
		ds 		64

COMExecBuffer:
		ds 		64 									; buffer for direct execution
COMARegister:
		dw 		0 									; Registers in execute mode
COMBRegister:
		dw 		0

DICTLastTypeByte:						
		dw 		0									; address of last type byte.
DICTTarget:
		db 		0 									; $00 = Forth, $40 = Macro

CFCount:											; Count bytes for fill and copy.
		dw 		0 


AlternateFont: 										; alternate font.
		include "font.inc"							; Daniel Hepper's Font.

FreeMemory:
		org 	$C000
		ds 		$4000								; end of dictionary marker.
		