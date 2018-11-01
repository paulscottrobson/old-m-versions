; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		loader.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Source loader
;		Created : 	23rd October 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;									Load the bootstrap page
;
; ********************************************************************************************************

LOADBootstrap:
		call	DICTSetForthDictionary
		ld 		a,(SIBootstrapPage)
		call 	__LOADBootstrapPage
		jp 		HaltZ80

; ********************************************************************************************************
;
;										Bootstrap page A
;
; ********************************************************************************************************

; @forth bootstrap.page
		ld 		a,l
__LOADBootstrapPage:
		push 	bc
		push 	de
		push 	hl
		call 	PAGESwitch 							; switch to bootstrap code page
		ld 		a,5
		call 	IOSetColour
		ld 		hl,__LOADBootMessage
		call 	IOPrintString
		ld 		hl,$C000 							; current page being loaded.

__LOADBootLoop:
		ld 		a,6
		call 	IOSetColour
		ld 		a,'.'
		call 	IOPrintChar

		ld 		a,(hl) 								; look at that page, anything there ?
		cp 		EOS
		jr 		z,__LOADBootNext

		ld 		de,EditBuffer  						; set up to copy to edit buffer
		ld 		bc,EditBufferSize
		push 	hl 									; save bootstrap code pointer
		ldir 	
		ld 		hl,EditBuffer 						; look at edit buffer
		call 	PARSEReset 							; parse that string
__LOADBootParse:
		inc 	c
		ld 		a,c
		and 	7
		out 	($FE),a
		call 	PARSEGet 							; get a word
		jr 		c,__LOADBootParseDone 				; nothing to do
		push 	hl
		call 	COMCompileExecute 					; do it.
		pop 	hl
		jp 		c,__LOADErrorHandler 				; error ?
		jr 		__LOADBootParse

__LOADBootParseDone:
		pop 	hl 									; restore address
__LOADBootNext:
		ld 		de,EditBufferSize 					; add buffer size to HL
		add 	hl,de
		bit 	7,h 								; until wrapped round to $0000
		jr 		nz,__LOADBootLoop

		call 	PAGERestore 						; return to original page
		pop 	hl
		pop 	de
		pop 	bc
		ret

__LOADBootMessage:
		db 		"Bootstrapping ",0

__LOADErrorHandler:									; unknown word @ HL
		push 	hl
		ld 		a,' '
		call 	IOPrintChar
		ld 		a,7
		call 	IOSetColour
__LOADToEnd: 										; go to end of string
		ld 		a,(hl)
		push 	af
		and 	$3F
		xor 	$20
		add 	a,$20
		ld 		(hl),a
		inc 	hl
		pop 	af
		cp 		EOS
		jr 		nz,__LOADToEnd
		dec 	hl
		ex 		de,hl 								; append text to it.
		ld 		hl,__LOADErrorMessage
		ld 		bc,__LOADErrorMessageEnd-__LOADErrorMessage
		ldir
		pop 	hl
		jp 		ErrorHandlerHL

__LOADErrorMessage:
		db 		" - Unknown word in bootstrap",0
__LOADErrorMessageEnd:
