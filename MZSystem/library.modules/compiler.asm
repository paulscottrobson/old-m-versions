; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		compiler.asm
;		Purpose : 	Core compiler (Green words)
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Compile ASCIIZ word at HL as if it were Green. CS on error
;
; ***********************************************************************************************

COMCompile:
		push 	bc
		push 	de
		push 	hl

		ld 		e,l 								; save it in DE
		ld 		d,h
		call 	DICTFindWord 						; HL = addr B = type C = page CS = error
		jr 		nc,__COMWordCompile 				; if okay, do a word compilation.

		ex 		de,hl 								; get the word back

		ld 		a,(hl) 								; is it a string ?
		and 	$3F
		cp 		'"'
		jr 		z,__COMStringCompile

		call 	CONSTConvert 						; try it as a constant
		jr 		nc,__COMConstantCompile 			; if found do a constant compilation


		scf 										; otherwise return with error.
		ld 		hl,$0000
		ld 		bc,$0000

__COMExit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

; ==================================================================================================
;
;						Compile constant in HL and return with carry clear
;
; ==================================================================================================

__COMConstantCompile:
		ld 		a,$EB 								; compile EX DE,HL
		call 	MEMCompileByte
		ld 		a,$21 								; compile LD HL,xxxx
		call 	MEMCompileByte
		call 	MEMCompileWord 						; compile address
		xor 	a 									; clear carry
		jr 		__COMExit

; ==================================================================================================
;
;									Word: Address CHL, Type B
;
; ==================================================================================================

__COMWordCompile:
		ld 		a,b 			 					; get word type
		and 	7

		or 		a 									; type zero (word)
		jr 		z,__COMCallCompile 					; compile a fall to the word.

		cp 		1 									; type 1, which is constant
		jr 		z,__COMConstantCompile 				; compile the address as a constant.

		cp 		2 									; type 2, which is macro
		jr 		z,__COMExecuteMacro 				; go execute it.

w11:	jr 		w11

; ==================================================================================================
;
;								  Word at CHL, compile call to it
;
;	Long Call if :
;		Source and Target both in paged memory, but they are different pages
;		Source is in unpaged memory, target in paged memory.
;
; ==================================================================================================

__COMCallCompile:
		ld 		a,h 								; is target $0000-$BFFF
		cp 		$C0
		jr 		c,__COMShortCall 					; then short call using CALL.

		ld 		a,(SICodeFree+1) 					; if it is being called from $0000-$BFFF do a long call.
		cp 		$C0
		jr 		c,__COMLongCall

		ld 		a,(SICodePage) 						; both call and source are in $C000-$FFFF if C is not the
		cp 		c 									; current page, then do a long call.
		jr 		nz,__COMLongCall
;
;								This call uses the Z80 Call opcode
;
__COMShortCall:
		ld 		a,$CD 								; compile call
		call 	MEMCompileByte
		call 	MEMCompileWord 						; compile address
		xor 	a 									; clear carry
		jr 		__COMExit

__COMLongCall:
		call 	PAGECompileFarCall
		xor 	a 									; clear carry
		jr 		__COMExit
			

; ==================================================================================================
;
;								Execute word at CHL in context
;
; ==================================================================================================

__COMExecuteMacro:
		ld 		a,c 								; swicth to page
		call 	PAGESwitch

		ld 		de,__COMContinue 					; return here last
		push 	de
		push 	hl 									; return here (word) first

		ld 		hl,(COM_ARegister) 					; run in context.
		ld 		de,(COM_BRegister)
		ret
__COMContinue:
		ld 		(COM_ARegister),hl
		ld 		(COM_BRegister),de

		call 	PAGERestore 						; restore original page.
		xor 	a 									; clear carry
		jr 		__COMExit

; ==================================================================================================
;
;										Compile a string
;
; ==================================================================================================

__COMStringCompile:
		push 	hl 									; work out overall string length.
		ld 		b,$FF 								; including the quote.
__COMLength:
		ld 		a,(hl)
		inc 	hl
		inc 	b
		or 		a
		jr 		nz,__COMLength

		ld 		a,$18 								; JR xx
		call 	MEMCompileByte
		ld 		a,b 								; Offset is string length + 1 - " as ASCIIZ
		call 	MEMCompileByte

		pop 	hl
		ld 		de,(SICodeFree)						; address of the string
__COMCopy:
		inc 	hl 									; copy out the string - the quote + the terminating zero.
		ld  	a,(hl)
		cp 		'_'									; underscore to space
		jr 		nz,__COMNotUnderscore
		ld 		a,' '
__COMNotUnderscore:
		call 	MEMCompileByte
		djnz 	__COMCopy

		ex 		de,hl 								; HL contains string address
		jp 		__COMConstantCompile 				; compile as constant

