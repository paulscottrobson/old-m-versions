; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		crunch.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Crunch Dictionary (remove privates)
;		Date : 		14th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; @word crunch 
		push	ix
		ld 		ix,(SVDictionaryBase)				; scan point
__crunch_loop:
		ld		a,(ix+0) 							; exit if start of dictionary
		or 		a
		jr 		z,__crunch_exit
		bit 	6,(ix+4) 							; if not private, do next
		jr 		z,__crunch_next

		ld 		hl,(SVNextDictionaryFree) 			; HL = copy from here.

		push 	ix 									; BC = position
		pop 	bc 
		xor 	a 									
		sbc 	hl,bc 								; BC = count
		ld 		c,l 								; put count in BC
		ld 		b,h

		push 	ix 									; address in DE
		pop 	de
		ld 		l,(ix+0)							; length in HL
		ld 		h,0
		add 	hl,de 								; from in HL, to in DE

		ldir 										; block copy.
		jr 		__crunch_loop 						; do again at the same point.

__crunch_next:
		ld 		e,(ix+0)
		ld 		d,0
		add 	ix,de
		jr 		__crunch_loop

__crunch_exit:
		ld 		(SVNextDictionaryFree),ix 			; update next free position.
		pop 	ix
		ret
		