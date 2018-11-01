; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		process.asm
;		Purpose : 	Processes Red, White, Green and Yellow words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Process word. Word is an ASCIIZ string at HL. E is the colour. CS if error.
;
; ***********************************************************************************************

PROCProcessWord:
		push 	bc
		push 	de
		push 	hl

		ld 		a,e 								; dispatch on colour
		or 		a
		jr 		z,__PROCRedDefiningWord				; $00 red
		cp 		$80
		jr 		z,__PROCGreenDefiningWord 			; $80 green
		cp 		$C0
		jr 		z,__PROCYellowDefiningWord 			; $C0 yellow

													; $40 white just falls through, its a comment

__PROCExitOkay:
		xor 	a 									; clear carry flag.
__PROCExitWithCarry:
		pop 	hl
		pop 	de
		pop 	bc
		ret

; ==================================================================================================
;
;								Red defining word, name in HL
;
; ==================================================================================================


__PROCRedDefiningWord:
		call 	DICTAddWord 						; add word to dictionary.
		jr 		__PROCExitOkay

; ==================================================================================================
;
;								Green compiling word, name in HL
;
; ==================================================================================================

__PROCGreenDefiningWord:
		call 	COMCompile 							; compile that word in code.
		jr 		__PROCExitWithCarry 				; and return whatever carry that was.

; ==================================================================================================
;
;							   Yellow executing word, name in HL
;
; ==================================================================================================

__PROCYellowDefiningWord:
		push 	bc	 								; look up the word only to get the type ID.
		push 	hl
		call 	DICTFindWord
		ld 		a,b
		pop 	hl 	
		pop 	bc
		jr 		c,__PROCYDWNotForbidden 			; if it wasn't found it may be executable (constant)
		bit 	6,a 								; if bit 6 is clear, it is executable
		jr 		z,__PROCYDWNotForbidden
		scf 										; return with CS as cannot execute it.
		jr 		__PROCExitWithCarry

__PROCYDWNotForbidden:
		ld 		de,(SICodeFree) 					; current value where code is being written.
		push 	de 									; save on the stack.
		ld 		de,PROCExecBuffer 					; set to compile into the execute buffer.
		ld 		(SICodeFree),de

		call 	COMCompile 							; compile whatever it was, returning CC if okay
		push 	af 									; save carry flag status
		ld 		a,$C9 								; compile a RET in the buffer.
		call 	MEMCompileByte 
		pop 	af 									; restore Carry Flag status
		pop 	de 									; restore code written address
		ld 		(SICodeFree),de
		jr 		c,__PROCExitWithCarry 				; if carry was set, then you can't run it, return CS

		ld 		hl,(COM_ARegister) 					; run in context.
		ld 		de,(COM_BRegister)
		call 	PROCExecBuffer
		ld 		(COM_ARegister),hl
		ld 		(COM_BRegister),de

		jr 		__PROCExitOkay
