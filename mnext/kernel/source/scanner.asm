; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		scanner.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd September 2018
;		Purpose :	Extract word from memory somewhere
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;							Set Buffer area to HL .. DE
;
; ***************************************************************************************

SCANSetup:
		ld 		(SCANStart),hl
		ld 		(SCANEnd),de
		ret

; ***************************************************************************************
;
;						Get a word from the buffer, return CS if failed
;
;	Preserves BC,DE,HL
; ***************************************************************************************

SCANGetWord:
		push 	bc
		push 	de
		push	hl
		ld 		hl,(SCANStart)						; start and end into HL
		ld 		de,(SCANEnd)
__SCANSkipSpaces:
		call 	__SCANGetCharacter 					; get a character
		jr 		c,__SCANExit 						; failed.
		ld 		b,a 								; save in B
		and 	$3F 								; is it space in 6 bit ASCII
		cp 		$20
		jr 		z, __SCANSkipSpaces
		xor 	a 									; zero word buffer length byte
		ld 		(WordBuffer),a
		ld 		a,b 								; get character read that's not space
		ld 		bc,WordBuffer+1 					; BC points to first character
		ld 		(bc),a 								; save character
__SCANGetWord:
		inc 	bc 									; next slot in word buffer
		ld 		a,(WordBuffer)						; increment length
		inc 	a
		ld 		(WordBuffer),a
		call 	__SCANGetCharacter 					; get the next character
		jr 		c,__SCANOkay 						; if CS, then end buffer but word read
		ld 		(bc),a 								; save in next buffer slot
		and 	$3F 								; go back if not space
		cp 		$20
		jr 		nz,__SCANGetWord
__SCANOkay: 										; return with carry clear
		xor 	a
__SCANExit: 										; return
		ld 		(ScanStart),hl 						; update the start position.
		pop 	hl
		pop 	de
		pop 	bc
		ret
;
;		Get character, return CS if none (e.g. HL == DE), CC if found
;
__SCANGetCharacter:
		ld 		a,l 								; if L != E okay
		cp 		e
		jr 		nz,__SCANNotEnd
		ld 		a,h 								; if H == D and L == E completed.
		cp 		d
		scf
		ret 	z 									; so return with CS

__SCANNotEnd:
		xor 	a 									; clear carry
		ld 		a,(hl) 								; read character
		inc 	hl 									; advance
		ret
		
SCANStart:
		dw 		0
SCANEnd:
		dw 		0

