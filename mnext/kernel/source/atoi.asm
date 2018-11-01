; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		atoi.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd September 2018
;		Purpose :	Convert word to integer.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;			Convert word-buffer to integer, CS if error else number in HL.
;
;				supports ddddd and $hhhhh formats with - prefixes
;
; ***************************************************************************************

ATOIConvert:
		push 	bc
		push 	de
		ld 		de,WordBuffer 						; point to buffer
		ld 		hl,$0000 							; reset result.
		ld 		a,(de)								; get length into B
		ld 		b,a 								
		inc 	de 									; DE points to first
		ld 		a,(de) 								; first character in C (sign test)
		and 	$3F 								; is it a sign.
		ld 		c,a
		cp 		'-'
		jr 		nz,__ATOIUnsigned
		inc 	de 									; if signed bump pointer
		dec 	b 									; dec char counter
		jr 		z,__ATOIFail 						; if '-'  only it fails
__ATOIUnsigned:
		ld 		a,(de) 								; check for '$' sign
		and 	$3F
		cp 		'$'
		jr 		z,__ATOIHex
;
;		decimal conversion
;
__ATOIDecimal:
		push 	de 									; x HL by 10
		ld 		e,l
		ld 		d,h
		add 	hl,hl 							
		add 	hl,hl
		add 	hl,de
		add 	hl,hl
		pop 	de

		ld 		a,(de) 								; get next character
		inc 	de

		and 	$3F 								; convert to 0-9 and check.
		sub		'0'
		jr 		c,__ATOIFail 
		cp 		10
		jr 		nc,__ATOIFail

		add 	a,l 								; add to HL
		ld 		l,a
		jr 		nc,__ATOINoCarry
		inc 	h
__ATOINoCarry:
		djnz 	__ATOIDecimal 						; completed ?
__ATOISuccess:
		ld 		a,c 								; check for minus sign up front
		cp 		'-'
		jr 		nz,__ATOINoNegate
		ex 		de,hl 								; HL negated if provided.
		ld 		hl,0
		xor 	a
		sbc 	hl,de
__ATOINoNegate:
		xor 	a 									; clear carry.		
		jr 		__ATOIExit

__ATOIFail:
		scf
__ATOIExit:
		pop 	de
		pop 	bc
		ret

;
;		Hexadecimal
;
__ATOIHex:
		inc 	de 									; skip '$'
		dec 	b
		jr 		z,__ATOIFail 						; fail if only a dollar

__ATOIHexLoop:
		add 	hl,hl 								; x by 16
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		ld 		a,(de) 								; get character		
		and 	$3F  								; convert to hex
		jr 		z,__ATOIFail
		cp 		48
		jr 		nc,__ATOIBefore0
		add 	a,48+9
__ATOIBefore0:
		sub 	48
		cp 		$10 								; range bad
		jr 		nc,__ATOIFail
		or 	 	l 									; or into L
		ld 		l,a
		inc 	de
		djnz 	__ATOIHexLoop
		jr 		__ATOISuccess

