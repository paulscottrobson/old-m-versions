; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		word.asm
;		Purpose : 	Word Processing code
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;										Process a word
;
; ***********************************************************************************************
;
;	On entry, HL points to the word in 6/7 bit ASCII, final char has bit 7 set.
;			  E  contains the word colour (00 Red 40 White 80 Green C0 Yellow)
;
;	On exit	  CS indicates an error,  CC if successful.
;
; ***********************************************************************************************

WORDProcessWord:
		push 	bc 
		push 	de
		ld 		a,e 								; examine the colour.
		cp 		$00 								; if $00 (red) then define the word.
		jr 		z,__WORDRedWord
		cp 		$80 								; if $80 (green) then its a compilation word
		jr 		z,__WORDGreenWord
		cp 		$C0 								; if $C0 (yellow) it's an execution word.
		jr 		z,__WORDYellowWord
		xor 	a 									; must've been $40 (white) comment so clear C
__WPExit:
		pop 	de
		pop 	bc
		ret

; ================================================================================================
;
;		Red (definition) word. This just uses the name to define a new dictionary word.
;
; ================================================================================================

__WORDRedWord:
		call 	DICTAppend 							; append the word to the dictionary
		xor 	a 									; clear the carry
		jr 		__WPExit

; ================================================================================================
;
;		Yellow (execution) word, which executes the compiler to generate some code to
; 		run the word. To do this, it changes CodeAddress to compile it in 
; 		a small buffer, writes CodeAddress back, then executes that code.
;
;		If it is calling an address in paged memory the PAGECompileCall routine detects
;		it's calling from unpaged to paged memory and always compiles a page switch.
;
; ================================================================================================

__WORDYellowWord:
		push 	bc
		push 	de
		push 	hl

		ld 		bc,(CodeAddress)	 				; push free code memory address on the stack
		push 	bc

		ld 		bc,ExecuteBuffer 					; set it so it compiles to here now.
		ld 		(CodeAddress),bc

		call 	__WORDGreenCompileCode 				; try to compile it.
		jr 		c,__WYFail 							; failed miserably, restore code pointer and exit.

		ld 		a,$C9 								; compile return from subroutine
		call 	PAGECompileByte 					; after the code to execute the word is there.

		pop 	bc 									; restore code pointer
		ld 		(CodeAddress),bc

		ld 		hl,(AWord) 							; set up environment
		ld 		de,(BWord)
		call 	ExecuteBuffer						; run the code.
		ld 		(BWord),de 							; save environment back
		ld 		(AWord),hl
		xor 	a 									; clear carry
		jr 		__WYExit

__WYFail:
		pop 	bc 									; restore code pointer
		ld 		(CodeAddress),bc
__WYExit:
		pop 	hl
		pop 	de
		pop 	bc
		jr 		__WPExit

; ================================================================================================
;		
;	Green (compilation) word. Looks up the word ; if the type is 0 compile a call, 1 compile
; 	a constant load, 2 call the routine and it does what it wants.
;
; ================================================================================================

__WORDGreenWord:
		call 	__WORDGreenCompileCode 				; compile the appropriate code.
		jr 		__WPExit 							; return with whatever that came back with.
;
;	This is the Green compile code, which is also used by Execute
;
__WORDGreenCompileCode:

		ld 		d,h 								; save address in DE.
		ld 		e,l
		call 	DICTFind 							; find it in the dictionary.
		jp 		c,__WGCCNotInDictionary
;
;		Dictionary word, execute address in CHL, type in B.
;
		ld 		a,b 								; so, what type is this word ?
		and 	$07 								; lower 3 bits are type ID.
		cp 		$00 								; type 0 is a code word
		jr 		z,__WGCCCodeWord
		cp 		$01									; type 1 is a constant word
		jr 		z,__WGCCConstantWord
		cp 		$02
		jr 		z,__WGCCMacroWord 					; type 2 is a macro word.
__WGCCInternal: 									; we should not get here.
		jr 		__WGCCInternal		
;
;		Word type 0 - a compiled word.
;
__WGCCCodeWord:
		ld 		a,(CodePage) 						; current code page into B
		ld 		b,a
		call 	PAGECompileCall 					; compile call to CHL from page B
		xor 	a 									; return with clear carry.
		ret
;
;		Word type 1 - a constant word.
;
__WGCCConstantWord:
		call 	__WORDCompileLoadConstant 			; compile code to load constant in HL
		xor 	a 									; return with clear carry.
		ret
;
;		Word type 2 - a macro word.
;
__WGCCMacroWord:
		call 	__WORDExecuteCHL 					; execute the word at CHL.
		xor 	a
		ret

;
;		Word isn't in the dictionary.
;
__WGCCNotInDictionary:
		ex 		de,hl 								; HL now points to the word.
		call 	__WORDCheckIsConstant 				; is the word a constant.
		ret 	c 									; if not, return with CS.
		call 	__WORDCompileLoadConstant 			; compile code to load constant.
		xor 	a 									; return with clear carry.
		ret

; ================================================================================================
;
;			Convert the word in the buffer to an integer in HL if possible, CS = error
;
; ================================================================================================

__WORDCheckIsConstant:
		push 	bc
		push 	de
		ex 		de,hl 								; pointer in DE
		ld 		hl,$0000 							; current result in HL.
__WORDCICLoop:
		ld 		b,h 								; HL -> BC
		ld 		c,l
		add 	hl,hl 								; HL x 4
		add 	hl,hl		
		add 	hl,bc 								; HL x 5
		add 	hl,hl 								; HL x 10
		ld 		a,(de) 								; next character
		and 	$3F 								; make 6 bit
		cp 		'0' 								; check in range
		jr 		c,__WORDCICFail 					; failed
		cp 		'9'+1 								
		jr 		nc,__WORDCICFail
		and 	15 									; put in BC
		ld 		c,a
		ld 		b,0
		add 	hl,bc
		ld 		a,(de) 								; get character back
		inc 	de 									; go to next.
		bit 	7,a 								; until end of character
		jr 		z,__WORDCICLoop
		xor 	a 									; done it, so clear carry
		jr 		__WORDCICExit 						; and exit with HL having the answer
__WORDCICFail:
		scf
__WORDCICExit:
		pop 	de
		pop 	bc
		ret

; ================================================================================================
;
;								Execute the code at CHL
;
; ================================================================================================

__WORDExecuteCHL:
		push 	af
		push 	bc
		push 	de
		push 	hl
		ld 		a,c 								; page number again.
		call 	PAGESet 							; go to that page.
		push 	af 									; save the return page on the stack.
		ld 		de,__WORDECHLExit 					; push the continuation on the stack.
		push 	de
		push 	hl 									; code we want to execute.
		ld 		hl,(AWord) 							; load A+B 
		ld 		de,(BWord)
		ret 
__WORDECHLExit:
		ld 		(BWord),de 							; write A+B back
		ld 		(AWord),hl
		pop 	af 									; the original page setting
		call 	PAGESet
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ================================================================================================
;
;						Compile code to load constant that is in HL
;
; ================================================================================================

__WORDCompileLoadConstant:
		push 	af
		ld 		a,$EB 								; EX DE,HL operation code
		call 	PAGECompileByte
		ld 		a,$21 								; LD HL,xxxx operation code
		call 	PAGECompileByte
		call 	PAGECompileWord
		pop 	af
		ret

AWord: 												; A + B values when executing things.
		dw 		0
BWord:
		dw 		0
