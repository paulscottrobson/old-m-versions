; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		variable.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Variable routine
;		Date : 		16th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; @word variable macro

		call 	cbGetWord 							; get name of variable
		jr 		c,__varError 						; missing variable name
		inc 	(hl) 								; one extra character
		ld 		a,'@'								; create xxxx@
		call 	__varCreate
		ld 		a,'!'								; create xxxx!
		call 	__varCreate
		ld 		a,'&'								; create xxxx&
		call 	__varCreate
		ld 		hl,0 								; allocate space for it
		call 	CompileWord
		ret

__varCreate:
		push 	hl 									; save start
		ld 		e,(hl)								; point HL at last char
		ld 		d,0
		add 	hl,de
		and 	$3F 								; make it 6 bit
		ld 		(hl),a 								; update last character
		pop 	hl 									; restore start
		call 	DefineNewWord 						; define it
		ld 		a,$C0 								; make it private/macro e.g. special case
		call 	SetLastEntryBit 
		ret

__varError: 										; not found
		ld 		hl,__varMissingMsg
		jp 		ErrorHandler
__varMissingMsg:
		db  	__varMissingMsgEnd-__varMissingMsg+1
		db 		"MISSING VARIABLE NAME"
__varMissingMsgEnd:

;
;		Generate code. On entry HL points to the control/length byte of the dictionary entry.
;
VARGenerateCode:
		push 	de
		push 	hl

		push 	hl 									; get the character that's a modifier.
		ld 		a,(hl)
		and 	$3F
		ld 		e,a
		ld 		d,0
		add 	hl,de
		ld 		a,(hl)
		and 	$3F		
		pop 	hl 									; restore HL
		dec 	hl 									; point to address
		dec 	hl
		dec 	hl
		ld 		e,(hl)								; read address
		inc 	hl
		ld 		h,(hl)
		ld 		l,e
		cp 		'@' & $3F 							; generate appropriate code
		call 	z,__varReadCode
		cp 		'!' & $3F
		call 	z,__varWriteCode
		cp 		'&' & $3F
		call 	z,__varAddressCode

		pop 	hl
		pop 	de
		ret

__varReadCode:
		push 	af
		ld 		a,$EB
		call 	CompileByte
		ld 		a,$2A
		call 	CompileByte
		call 	CompileWord
		pop 	af
		ret

__varWriteCode:
		push 	af
		ld 		a,$22
		call 	CompileByte
		call 	CompileWord
		pop 	af
		ret

__varAddressCode:
		push 	af
		ld 		a,$EB
		call 	CompileByte
		ld 		a,$21
		call 	CompileByte
		call 	CompileWord
		pop 	af
		ret
