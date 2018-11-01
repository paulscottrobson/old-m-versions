; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		variable.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Variable code
;		Date : 		7th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;										Create a new variable
;
; ********************************************************************************************************

VARCreate:
		push 	hl

		call 	SCANGetWord 						; get word, error if none.
		jr 		c,__VCError

		ld 		hl,WordBuffer 						; increment length by one to allow for &!@
		inc 	(hl)
		ld 		a,'@'								; create the three useful words.
		call 	__VARCCreate
		ld 		a,'!'
		call 	__VARCCreate
		ld 		a,'&'
		call 	__VARCCreate

		ld 		hl,(FreeDataAddress)				; advance the data address by two
		inc 	hl
		inc 	hl
		ld 		(FreeDataAddress),hl 

		pop 	hl
		ret
;
;		Create word ending in 'A' character that has the address of the next free data address.
;
__VARCCreate:
		push 	bc
		push 	de
		push 	hl
		ld 		hl,WordBuffer 						; point to last character
		ld 		e,(hl)
		ld 		d,0
		add 	hl,de
		ld 		(hl),a 								; overwrite character

		ld 		c,FirstCodePage 					; in the first code page
		ld 		b,$C0 								; flag byte
		ld 		hl,(FreeDataAddress)				; data address for this word.
		call 	DICTCreate 							; create the word.

		pop 	hl
		pop 	de
		pop 	bc
		ret
;
;		Nothing found so can't name the variable
;
__VCError:											; nothing to be a variable.
		ld 		hl,__VCErrorMessage
		jp 		PRPWReportError
__VCErrorMessage:
		db 		"MISSING VARIABLE NAME",0


; ********************************************************************************************************
;
;								Compile the variable code (bit 6 set)
;
; ********************************************************************************************************

VARCompileSpecial:
		push 	de 									; save registers
		push 	hl
		push 	hl 									; save variable address
		ld 		hl,WordBuffer
		ld 		e,(hl) 								; find end of name being compiled ( == type )
		ld 		d,0
		add 	hl,de
		ld 		a,(hl) 								; get last character
		and 	$3F 								; make 6 bit
		pop 	hl 									; HL is now variable address
		cp 		'&' 
		jr 		z,__VARCSAddress
		cp 		0 									; @
		jr 		z,__VARCSLoad
		cp 		'!' 
		jr 		z,__VARCSStore

__VARCSFail: 										; internal error.
		jr 		__VARCSFail

__VARCSLoad:
		ld 		a,$EB 								; ex de,hl
		call 	FMCompileByte
		ld 		a,$2A 								; ld hl,(xxxx)
		call 	FMCompileByte
		call 	FMCompileWord
		jr 		__VARCSExit

__VARCSAddress:
		ld 		a,$EB 								; ex de,hl
		call 	FMCompileByte
		ld 		a,$21								; ld hl,xxxx
		call 	FMCompileByte
		call 	FMCompileWord
		jr 		__VARCSExit

__VARCSStore:
		ld 		a,$22 								; ld (xxxx),hl
		call 	FMCompileByte
		call 	FMCompileWord
		jr 		__VARCSExit

__VARCSExit:
		pop 	hl
		pop 	de		
		ret

