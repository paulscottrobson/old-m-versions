; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		core.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	core assembly file
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

SplitPoint = $8000 									; where RAM is split. Can move

		org 	$4080
		incbin 	"testdata.bin"

; ********************************************************************************************************
;
;												Boot code
;
; ********************************************************************************************************

		opt 	zxNext
		org 	$5B00

ColdStart: 
		ld 		sp,stackTop 						; Initialise the stack
		ld 		hl,(SVRunAddress)					; what do we run ?
		jp 		(hl) 								; go there

HaltCode:											; come here to stop the CPU
		halt
		jr 		HaltCode

CompileScreenBlockCode:
		ld 		hl,$4080 							; compile code from here to here. Put at $4080
		ld 		de,$59FF 							; as SNASM grabs a few screen bytes
		call 	CompileBlock
		jr 		HaltCode

; ********************************************************************************************************
;
;						Functions where speed not particularly important
;
; ********************************************************************************************************

		include "support/hardware.asm"				; screen and keyboard
		include "support/multiply.asm"				; 16 bit multiply
		include "support/divide.asm" 				; 16 bit divide
		include "compiler.asm" 						; base compiler code

; ********************************************************************************************************
;
;												Data Area
;
; ********************************************************************************************************

stackBegin:											; Z80 Return stack.
		ds 		128 
stackTop:
		dw 		0

SystemVariables:
		
SVRunAddress:
		dw 		CompileScreenBlockCode				; +0,+1 	run address
SVMacroDictionary:
		dw		DictionaryEnd 						; +2,+3 	first element on macro dictionary
SVStandardDictionary:								
		dw 		DictionaryEnd 						; +4,+5 	first element on standard dictionary
SVNextDictionaryFree: 
		dw 		DictionaryNextFree 					; +6,+7 	dictionary next free byte
SVCurrentDictionary:						
		dw 		SVStandardDictionary				; +8,+9 	address of first element of selected dictionary
SVNextProgramFree: 	
		dw 		ProgramNextFree						; +10,+11 	program next free byte
SVNextProgramFreePage:
		db 		0,$FF								; +12   	page number program next free byte

; ********************************************************************************************************
;
;											   Dictionary Area
;
; ********************************************************************************************************

DictionaryEnd:
		dw 		0 									; the $0000 address indicating end of dictionary
DictionaryNextFree:

;
;		+0,+1 			link to previous entry. When $0000 reached the start
;		+2,+3			address of code
;		+4 				page number of code
;		+5 				first character of name, 6 bit ASCII
;		+6 				second character of name, 6 bit ASCII
;		+5+name.length	last character of name, 6 bit ASCII, bit 7 set
;

; ********************************************************************************************************
;
;										 Uncontended memory area
;
; ********************************************************************************************************

		org 	SplitPoint

ProgramNextFree:

		savesna "core.sna", ColdStart
