; *********************************************************************************
; *********************************************************************************
;
;		File:		copyfill.asm
;		Purpose:	Data Copy and Fill
;		Date:		24th September 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;							Fill C bytes with B starting at A
; *********************************************************************************
	
FillWord:
		push 	ix
		pop 	bc
		ld 		a,b
		or 		c
		ret 	z

		push 	hl
		
__fill1:ld 		(hl),e

		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__fill1

		pop 	hl
		ret

; *********************************************************************************
;							Copy C bytes from B to A
; *********************************************************************************

CopyWord:
		push 	ix
		pop 	bc

		push 	de
		push 	hl

		ld 		a,b 								; exit now if count zero.
		or 		c
		jr 		z,__copyExit

		xor 	a 									; find direction. 
		sbc 	hl,de
		ld 		a,h
		add 	hl,de
		bit 	7,a 								; if +ve use LDDR
		jr 		z,__copy2

		ex 		de,hl 								; LDIR etc do (DE) <- (HL)
		ldir
__copyExit:
		pop 	hl
		pop 	de
		ret

__copy2:		
		add 	hl,bc 								; add length to HL,DE, swap as LDDR does (DE) <- (HL)
		ex 		de,hl
		add 	hl,bc
		dec 	de 									; -1 to point to last byte
		dec 	hl
		lddr 
		jr 		__copyExit		
