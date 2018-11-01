; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		constant.asm
;		Purpose : 	Constant conversion (ASCIIZ -> HL)
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;				Convert ASCIIZ string at HL to constant at HL ; CS if error
;
; ***********************************************************************************************

CONSTConvert:

		push 	bc
		push 	de
		
		ex 		de,hl 								; pointer in DE
		ld 		hl,$0000 							; current result in HL.
__CONSTLoop:
		ld 		a,(de)								; look at character
		or 		a 									; check if zero
		jr 		z,__CONSTExit 						; if so exit with Carry Clear and result in HL

		ld 		b,h 								; HL -> BC
		ld 		c,l
		add 	hl,hl 								; HL x 4
		add 	hl,hl		
		add 	hl,bc 								; HL x 5
		add 	hl,hl 								; HL x 10

		ld 		a,(de) 								; next character
		and 	$7F 								; make 6 bit
		cp 		'0' 								; check in range
		jr 		c,__CONSTFail 						; failed
		cp 		'9'+1 								
		jr 		nc,__CONSTFail
		and 	15 									; put in BC
		ld 		c,a
		ld 		b,0
		add 	hl,bc
		inc 	de 									; go to next.
		jr 		__CONSTLoop

		xor 	a 									; done it, so clear carry
		jr 		__CONSTExit 						; and exit with HL having the answer

__CONSTFail:
		scf
		ld 		hl,$0000
__CONSTExit:
		pop 	de
		pop 	bc
		ret