; *********************************************************************************
; *********************************************************************************
;
;		File:		copyfill.asm
;		Purpose:	Data Copy and Fill
;		Date:		29th October 2018
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;						Fill C bytes with B starting at A
;
; *********************************************************************************

__zfdefine_66_69_6c_6c:
; @word fill
;; fill the number of bytes saved using count! with B, starting at address A

		ld 		a,b
		or 		c
		ret 	z

		push 	bc
		push 	hl

__fill1:ld 		(hl),e

		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__fill1

		pop 	hl
		pop 	bc
		ret

; *********************************************************************************
;
;							Copy C bytes from B to A
;
; *********************************************************************************

__zfdefine_63_6f_70_79:
; @word copy


		ld 		a,b 								; exit now if count zero.
		or 		c
		ret 	z

		push 	bc
		push 	de
		push 	hl

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
		pop 	bc
		ret

__copy2:
		add 	hl,bc 								; add length to HL,DE, swap as LDDR does (DE) <- (HL)
		ex 		de,hl
		add 	hl,bc
		dec 	de 									; -1 to point to last byte
		dec 	hl
		lddr
		jr 		__copyExit
