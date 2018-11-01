; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		parser.asm
;		Purpose : 	Parse text for words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;							Set the range of the text from DE->HL
;
; ***********************************************************************************************

PARSESetBuffer:
		ld 		(PARSECurrent),de
		ld 		(PARSEEnd),hl
		ret

; ***********************************************************************************************
;
;		Read next word into parse buffer. Return CS if failed, CC if succeeded with 
; 		HL pointing to the buffer (ASCIIZ) and E containing the colour.
;
; ***********************************************************************************************

PARSENextWord:
		push 	bc
		ld 		hl,(PARSECurrent)					; HL = nwxt to scan
		ld 		de,(PARSEEnd) 						; DE = limit of scanning.
;
;		Find the first non-space character.
;
__PARSEFind:	
		call 	__PARSEGetCharacter 				; get the next character
		jr 		c,__PARSEExit 						; if non remaining then exit with carry set
		ld 		b,a 								; save in B
		and 	$3F 								; check to see if it is a space
		cp 		$20
		jr 		z,__PARSEFind 						; if so, go round again.

		ld 		a,b 								; retrieve first character
		and 	$C0 								; get the "colour bits" bits 6 and 7
		ld 		(PARSEWordType),a 					; and save in the type variable.
		ld 		a,b 								; retrieve it.
		ld 		bc,PARSEBuffer 						; BC points to the parse buffer
;
;		Copy word in ; BC points to next space in buffer, A is the char just read in.
;
__PARSELoop:
		and 	$3F 								; make it 6 bit ASCII
		xor 	$20 								; make it 7 bit ASCII
		add 	a,$20
		ld 		(bc),a 								; store in the parse buffer
		inc 	bc 									; bump parse buffer pointer.
		call 	__PARSEGetCharacter 				; get the next character.
		jr 		c,__PARSESucceed 					; if none left what we have so far is fine.
		ld 		(bc),a 								; save it here temporarily
		and 	$3F 								; check if it is a space
		cp 		$20
		ld 		a,(bc) 								; restore character, Z set if space.
		jr 		nz,__PARSELoop 						; if not space get another character.
;
;		Successfully found a word
;
__PARSESucceed:		
		xor 	a 									; make it ASCIIZ.
		ld 		(bc),a

		ld 		(PARSECurrent),hl 					; update the current char pointer.

		ld 		hl,PARSEBuffer 						; HL points to ParseBuffer
		ld 		a,(PARSEWordType)					; DE is the word type
		ld 		e,a
		ld 		d,0
		xor 	a 									; return with carry clear == okay.
;
;		Exit the next word parser.
;
__PARSEExit:
		pop 	bc
		ret

;
;		Read the next character into A, if none left return CS.
;
__PARSEGetCharacter:
		ld 		a,l 								; compare DE vs HL
		cp 		e
		jr 		nz,__PARSENotEnd
		ld 		a,h
		cp 		d
		scf  										; set carry flag in case equalled.
		ret 	z 									; DE = HL, end of buffer, exit with CS

__PARSENotEnd:
		ld 		a,(hl)								; get character
		inc 	hl 									; bump pointer
		or 		a 									; this clears the carry flag.
		ret

