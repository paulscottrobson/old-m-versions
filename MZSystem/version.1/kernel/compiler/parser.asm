; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		parser.asm
;		Purpose : 	Parse text for words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
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
; 		HL pointing to the buffer and DE containing the type/colour.
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
		and 	$3F 								; make it 6 bit ASCII and store it
		ld 		(bc),a 								; in the parse buffere
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
		xor 	a 									; make it ASCIIZ for clarity in debugger
		ld 		(bc),a

		dec 	bc 									; set bit 7 of the last character
		ld 		a,(bc)
		set 	7,a
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

PARSECurrent:										; next text to scan
		dw 		0
PARSEEnd: 											; end of text to scan
		dw 		0 

PARSEBuffer:										; buffer for parsed word
		ds 		32 									
PARSEWordType: 										; type of word read in to parse buffer.
		db 		0 									

