; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		datatransfer.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Copy and Fill routines
;		Date : 		3rd October 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ========================================================================================================
;								Set the count value for data transfer
; ========================================================================================================

; @word 		count!
		ld 		(DataTransferCount),hl
		ret
		
; ========================================================================================================
;								Fill [Count] bytes with A starting at B
; ========================================================================================================

; @word 		fill

		ld 		bc,(DataTransferCount)
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

; ========================================================================================================
;											Copy [Count] bytes from B to A
; ========================================================================================================

; @word 		copy

		push 	bc
		push 	de
		push 	hl

		ld 		bc,(DataTransferCount)
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
		pop 	bc
		ret

__copy2:		
;		db 		$DD,$01
		add 	hl,bc 								; add length to HL,DE, swap as LDDR does (DE) <- (HL)
		ex 		de,hl
		add 	hl,bc
		dec 	de 									; -1 to point to last byte
		dec 	hl
		lddr 
		jr 		__copyExit		

