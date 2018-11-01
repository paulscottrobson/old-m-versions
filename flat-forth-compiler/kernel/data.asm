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

SIDictionaryFree:
		dw 		$C000,0 							; +0  Next free byte in dictionary
SIDictionaryPage:
		dw 		$20,0								; +4 Page Number of dictionary
SIBootAddress:
		dw 		HaltZ80,0							; +8  Boot address
SIBootPage:	
		dw 		$22,0 								; +12 Boot page
SIStack:
		dw 		StackTop,0							; +16 Initial stack value
SIFontBase:	
		dw 		AlternateFont,0						; +20 Base address of font (space)
SIScreenWidth:
		dw 		32,0 								; +24 Screen width, characters
SIScreenHeight:
		dw 		24,0 								; +28 Screen height, characters
SIScreenManager:
		dw 		ZX48KPrint,0 						; +32 Hardware Console Driver
;		dw 		Layer2Print,0	
;		dw		LowResPrint,0

; ***************************************************************************************
;
;								 Other data and buffers
;
; ***************************************************************************************

StackTop   = 	$7FFF 								; Top of stack

IOColour:											; screen colour
		db 		7
IOCursorX: 											; position on screen.
		db 		0
IOCursorY:
		db 		0
CFCount: 											; count for fill and copy
		dw 		0,0

AlternateFont: 										; alternate font.
		include "font.inc"							; Daniel Hepper's Font.

		org 	$A000
FreeMemory:
		org 	$C000
		ds 		$4000								; end of dictionary marker.
		