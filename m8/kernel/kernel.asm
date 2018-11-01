; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		kernel.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	core assembly file
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

ifdef LOBOOT
BaseAddress = $5B00 								; build from here
ProgramSpace = $8000 								; program code here.
endif

ifdef HIBOOT
BaseAddress = $8000 								; build from here
ProgramSpace = $9800 								; program code here.
endif

BootCodeAddress = $4100								; boot code starts here
BootCodeEndAddress = $59FF	 						; boot code ends here

; ********************************************************************************************************
;
;												Boot code
;
; ********************************************************************************************************
	
		opt 	zxNext
		org 	BaseAddress
ColdStart:
		jr 		Boot
		dw 		SystemVariables 					; System variables address byte 2,3
		dw 		BaseAddress 						; Base address byte 4,5
Boot:
		di 											; disable interrupts.
		ld 		sp,stackTop 						; Initialise the stack
		ld 		hl,(SVRunAddress)					; what do we run ?
		jp 		(hl) 								; go there

ErrorHandler:
		ld 		ix,(SVErrorHandlerVector)
		jp 		(ix)
__EHShow:
		ld 		b,(hl)
__eh0:	inc 	hl
		ld 		a,(hl)
		and 	$3F
		call 	IOPrintCharacter
		djnz 	__eh0
		
HaltCode:											; come here to stop the CPU
		halt
		jr 		HaltCode

CompileScreenBlockCode:
		ld 		hl,BootCodeAddress 					; compile code from here to here. Put at $4100
		ld 		de,BootCodeEndAddress				; as SNASM grabs a few screen bytes
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
		include "compiler/compiler.asm" 			; base compiler code
		include	"compiler/extract.asm"				; extract words
		include "compiler/define.asm"				; add a new definition to the dictionary
		include "compiler/convert.asm"				; convert word to integer constant
		include "compiler/access.asm"				; paging dependent code generation
		include "compiler/find.asm"					; search dictionary code.
		include "compiler/comexec.asm"				; word compile/execute code
		include "__words.asm"						; generated words file.
		
; ********************************************************************************************************
;
;												Data Area
;
; ********************************************************************************************************

stackBegin:											; Z80 Return stack.
		ds 		128 
stackTop:
		dw 		0

bufferSize = 512 									; editor buffer

		dw 		0,0
buffer:	ds 		bufferSize
		dw 		0,0

SystemVariables:
		
SVRunAddress:
		dw 		CompileScreenBlockCode				; +0,+1 	run address
SVDictionaryBase:
		dw		DictionaryBase						; +2,+3 	dictionary base address
SVNextDictionaryFree: 
		dw 		DictionaryNextFree 					; +4,+5 	dictionary next free byte
SVNextProgramFree: 	
		dw 		ProgramNextFree						; +6,+7 	program next free byte
SVNextProgramFreePage:
		db 		0,$FF								; +8 	  	page number program next free byte
SVErrorHandlerVector:
		dw 		__EHShow 							; +10,+11 	error handler

; ********************************************************************************************************
;
;											   Dictionary Area
;
; ********************************************************************************************************

DictionaryBase:
DictionaryNextFree:
		db 		0

;
;		+0				offset to next entry. When zero, you are at the end of the dictionary.
;		+1,+2			address of code
;		+3 				page number of code
;		+4 				information 	Bit 7:Macro Bit 6:Private Bit 5-0:Length
;										Set as Private+Macro its modifiable with & ! @ etc.
;		+5 				first character of name, 6 bit ASCII
;		+6 				second character of name, 6 bit ASCII
;		+5+name.length	last character of name, 6 bit ASCII
;

; ********************************************************************************************************
;
;										 Uncontended memory area
;
; ********************************************************************************************************

		org 	ProgramSpace
ProgramNextFree:
		savesna	"kernel.sna",ColdStart
