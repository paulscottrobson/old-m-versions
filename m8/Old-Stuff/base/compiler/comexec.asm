; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		comexec.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Word compile/execute
;		Date : 		7th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;								Compile the word at HL
;
; ********************************************************************************************************

CompileOneWord:
	push 	af
	push 	hl 										; save address of word
	xor 	a
	call 	FindWord 								; check it is in dictionary
	jr 		nc,__COWFound 							; found that word.

	pop 	hl 										; restore the word text
	call 	ConvertWordToInteger 					; integer ?
	jr 		nc,__COWInteger 

__COWError:
	jp 		ErrorHandler
	
__COWExit:
	pop 	af
	ret

;
;		Compiling an integer
;
__COWInteger:
	ld 		a,$EB
	call 	CompileByte
	ld 		a,$21
	call 	CompileByte
	ex 		de,hl
	call 	CompileWord
	jr 		__COWExit	
;
;		Compiling a word.
;
__COWFound:

	pop 	de 										; no longer need the word text

	inc 	hl 										; get the address to DE
	ld 		e,(hl)
	inc 	hl
	ld 		d,(hl)
	inc 	hl	
	ld 		a,(hl) 									; page into A.

	inc 	hl 										; see if macro bit set
	bit 	7,(hl) 	
	jr 		nz,__COWExecMacro 						; do it as a macro

	ex 		de,hl 									; address is now in AHL
	call 	CompileCall 							; compile that call
	jr 		__COWExit
;
;		Execute ADE as a macro
;
__COWExecMacro:
	ex 		de,hl
	call 	ExecuteHLAWord
	jr 		__COWExit

; ********************************************************************************************************
;
;								Execute the word at HL
;
; ********************************************************************************************************

ExecuteOneWord:
	push 	af
	push 	hl 										; save word
	ld 		a,1 									; find only executables
	call 	FindWord 								; see if in dictionary
	jr 		nc,__EOWFound 							; if found execute it
	pop 	hl 										; restore it.
	call 	ConvertWordToInteger 					; is it an integer
	jr 		c,__COWError 							; if so, unknown word.
;
;		Found a constant so replicate the A->B const->A
;
	ld 		hl,(AWork) 								; do the load, so A->B
	ld 		(BWork),hl
	ld 		(AWork),de 								; save new number in B
	pop 	af 										; and return
	ret
;
;		Found executable (e.g. Non Macro) so get its addres and do it
;
__EOWFound:
	pop 	de
	inc 	hl 										; put address in DE
	ld 		e,(hl) 							
	inc 	hl
	ld 		d,(hl)
	inc 	hl
	ld 		a,(hl) 									; page in A
	ex 		de,hl 
	call 	ExecuteHLAWord  						; execute word at HLA
	pop 	af
	ret
