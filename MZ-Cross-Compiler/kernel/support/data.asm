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

PAGEStackPointer:									; paging undo stack pointer
		dw 		0
PAGEStack: 											; paging undo stack.
		dw 		0,0,0,0

IOCursorPosition: 									; cursor position in charactes
		dw 		0

StackInitialValue:									; Z80 Stack Space
		dw 		0
		