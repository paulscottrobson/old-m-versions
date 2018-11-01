; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		convert.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Convert word at HL (length prefix) to constant in DE, CS if can't convert
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

ConvertWordToInteger:
		push 	af
		push 	bc
		push 	hl

		push 	hl 									; add $20 to end of the string
		ld 		c,(hl)
		ld 		b,0
		add 	hl,bc
		inc 	hl
		ld 		(hl),$20
		pop 	hl
		inc 	hl 									; skip over length

		ld 		bc,10 								; B (sign) = 0, C (base) = 10

		ld 		a,(hl)								; check for leading '-'
		and 	$3F
		cp 		'-'
		jr 		nz,__cwiNotSigned
		inc 	b 									; set sign flag
		inc 	hl 									; skip over 
__cwiNotSigned:
		ld 		a,(hl) 								; check for '$'
		and 	$3F
		cp 		'$'
		jr 		nz,__cwiNotHexadecimal
		ld 		c,16 								; set to base 16
		inc 	hl 									; skip over 
__cwiNotHexadecimal:

		ld 		de,0 								; zero result.

		ld 		a,(hl) 								; is there anything at all ?
		and 	$3F
		cp 		$20 
		jr 		z,__cwiFail 						; if not, fail

__cwiConvertLoop:
		ld 		a,(hl) 								; get the next character
		and 	$3F
		jr 		z,__cwiFail 						; if 0 (@) found, then fail automatically
		cp 		$20 								; if space, then we've reached the end.
		jr 		z,__cwiSucceed 						; so return with CC.

		push 	af
		call 	__cwiMultiplyDEByC 					; multiply current by base
		pop 	af

		cp 		'9'+1 								; > '9' ?
		jr 		nc,__cwiFail
		sub 	'0' 								; if >= '0' 
		jr 		nc,__cwiFound  						; it's a legitimate value.
		add		'0'+9 								; convert to a 10+ value
__cwiFound:
		cp 		c 									; is it >= the base ?
		jr 		nc,__cwiFail 						; then fail

		add 	a,e 								; add this to DE
		ld 		e,a
		ld 		a,d
		adc 	a,0
		ld 		d,a

		inc 	hl 									; bump pointer
		jr 		__cwiConvertLoop 					; do the next

__cwiSucceed:
		ld 		a,b 								; was it signed ?
		or 		a
		jr 		z,__cwiNoSign
		ld 		hl,0 								; negate it.
		xor 	a
		sbc 	hl,de
		ex 		de,hl
__cwiNoSign:
		pop 	hl
		pop 	bc
		pop 	af
		and 	a 									; clear carry
		ret

__cwiFail:											; exit with carry flag set.
		ld 		de,$FFFF
		pop 	hl
		pop 	bc
		pop 	af
		scf 				
		ret

__cwiMultiplyDEByC:
		push 	bc
		push 	hl
		ld 		hl,$0000 							; result
__cwiMulLoop:
		bit 	0,c
		jr 		z,__cwiMulNotAdd
		add 	hl,de
__cwiMulNotAdd:
		srl 	c
		ex 		de,hl
		add 	hl,hl
		ex 		de,hl
		ld 		a,c
		or 		a
		jr 		nz,__cwiMulLoop
		ex 		de,hl
		pop 	hl
		pop 	bc
		ret
