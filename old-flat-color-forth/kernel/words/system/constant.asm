; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	22nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Convert ASCIIZ string at HL to constant in HL. DE 0, Carry Clear if true
;
; ***********************************************************************************************

; @forth const.convert
;; Convert the string pointed to by A into A constant in A, B is zero if it was successful.

CONSTConvert:
	push 	bc
	ex 		de,hl 									; string pointer in DE
	ld 		hl,$0000								; result in HL.
	ld 		b,0
	ld 		a,(de)									; check if -x
	and 	$3F
	cp 		'-'
	jr 		nz,__CONConvLoop
	inc 	b 										; B is sign flag
	inc 	de 										; skip over - sign.
__CONConvLoop:
	ld 		a,(de)									; get next
	inc 	de
	cp 		EOS 									; if end of string, completed.	
	jr 		z,__CONConComplete
	and 	$3F
	cp 		'0'										; must be 0-9 otherwise
	jr 		c,__CONConFail
	cp 		'9'+1
	jr 		nc,__CONConFail

	push 	bc
	push 	hl 										; HL -> BC
	pop 	bc
	add 	hl,hl 									; HL := HL * 4 + BC 
	add 	hl,hl
	add 	hl,bc 						
	add 	hl,hl 									; HL := HL * 10
	ld 		b,0 									; add the digit into HL
	and 	15
	ld 		c,a
	add 	hl,bc
	pop 	bc
	jr 		__CONConvLoop 							; next character

__CONConFail: 										; didn't convert
	ld 		hl,$FFFF
	ld 		de,$FFFF
	scf
	pop 	bc
	ret

__CONConComplete:									; did convert
	ld 		a,b
	or 		a
	jr 		z,__CONConNotNegative

	ld 		a,h 									; negate HL
	cpl 	
	ld 		h,a
	ld 		a,l
	cpl
	ld 		l,a
	inc 	hl

__CONConNotNegative:
	ld 		de,$0000
	xor 	a 										; clear carry
	pop 	bc
	ret
