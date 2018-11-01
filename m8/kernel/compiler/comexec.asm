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

	inc 	hl 										; is it a string ?
	ld 		a,(hl)
	dec 	hl
	and 	$3F
	cp 		'"'
	jr 		z,__COWString

	push 	hl 										; save address of word
	xor 	a
	call 	FindWord 								; check it is in dictionary
	jr 		nc,__COWFound 							; found that word.

	pop 	hl 										; restore the word text
	call 	ConvertWordToInteger 					; integer ?
	jr 		nc,__COWInteger 

__COWError:											; word unknown error
	ld 		c,l 									; put length address in BC
	ld 		b,h
	ld 		e,(hl)									; DE = length
	ld 		d,0
	add 	hl,de 									; HL is now last character
	ld 		de,__COWText 							; this is appended text
__COWPad:
	ld 		a,(de)									; character to append
	or 		a
	jp 		z,__COWGoError 							; $00 = end
	inc 	hl 										; write character
	ld 		(hl),a
	inc 	de 										; next character
	ld 		a,(bc) 									; increment length
	inc 	a
	ld 		(bc),a
	jr 		__COWPad

__COWGoError:
	ld 		l,c 									; restore HL
	ld 		h,b
	jp 		ErrorHandler

__COWText:
	db 		" UNKNOWN WORD",0
__COWExit:
	pop 	af
	ret

;
;		Compiling an integer DE
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
	bit 	6,(hl) 									; is it a special case (e.g. macro AND private
	jr 		nz,__COWPrivateMacro
	ex 		de,hl
	call 	ExecuteHLAWord
	jr 		__COWExit
;
;		Private Macro
;
__COWPrivateMacro:
	call 	VARGenerateCode 						; HL points to the control byte
	jr 		__COWExit

;
;		String at HL
;
__COWString:
	ld 		a,$18 									; Z80 JR Instruction
	call 	CompileByte
	ld 		a,(hl) 									; this is actual length + 1 because of the
	call 	CompileByte 							; leading quote
	ld 		de,(SVNextProgramFree)					; DE is the address of the string
	dec 	a 										; actual size
	inc 	hl 										; skip over size and quote
	inc 	hl
	call 	CompileByte
	ld 		b,a 									; put in B
__COWSLoop: 										; output the string
	ld 		a,(hl)
	and 	$3F
	cp 		'_' & $3F 								; convert _ to space
	jr 		nz,__COWSNotSpace
	ld 		a,' '
__COWSNotSpace:
	call 	CompileByte
	inc 	hl
	djnz 	__COWSLoop
	jr 		__COWInteger 							; compile DE as integer.

	jp 		__COWExit


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
	jp 		c,__COWError 							; if so, unknown word.
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
