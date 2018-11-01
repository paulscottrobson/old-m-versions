; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		29th October 2018
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
		dw 		$3D00,0								; +32 Base address of font (space)
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

StackTop   = 	$7FFE 								; Top of stack


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

COMIsCompileMode: 									; 0 = execute mode, #0 = compiler mode.
		db 		0

COMARegister:
		dw 		0 									; Registers in execute mode (or macros in
COMBRegister:										; compile mode)
		dw 		0
COMCRegister:
		dw 		0

DICTLastTypeByte:						
		dw 		0									; address of last type byte.

CFCount:											; Count bytes for fill and copy.
		dw 		0 


AlternateFont: 										; alternate font.
		include "font.inc"							; Daniel Hepper's Font.

		org 	$A000
FreeMemory:
		org 	$C000
		ds 		$4000								; end of dictionary marker.
		