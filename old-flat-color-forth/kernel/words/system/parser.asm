; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		parsing.asm
;		Purpose : 	Parsing code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	22nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;								Reset,parsing pointer (to HL)
;
; ***********************************************************************************************

; @forth parser.setup
;; set the parser to parse the ASCIIZ string at A.

PARSEReset:
	ld 		(PARSEPointer),hl
	ret

; ***********************************************************************************************
;
;		   Get next word. Returns pointer to word parsed in HL, and CC, or HL = 0 and CS.
;
; ***********************************************************************************************

; @forth parser.get
;; Read word from the parser source into the buffer, and return its address in A.  If no word
;; is available, return zero.

PARSEGet:
	push 	bc
	push 	de
	ld 		hl,(PARSEPointer)
__PGSkipSpaces:
	ld 		a,(hl) 									; get first character, save in B
	ld 		b,a
	cp 		EOS 									; if string end
	jr 		z,__PGFail
	inc 	hl 										; bump pointer
	and 	$3F 				
	cp 		' ' 									; loop back if space
	jr 		z,__PGSkipSpaces
	ld 		de,PARSEBuffer 							; DE is the buffer.
__PGLoadBuffer:
	ld 		a,b
	ld 		(de),a 									; copy text into buffer
	inc 	de
	ld 		a,(hl) 									; get next character, save in B
	ld 		b,a
	cp 		EOS										; if stromg emd, done
	jr 		z,__PGReadWord
	inc 	hl 										; bump pointer.
	and 	$3F
	cp 		' ' 									; if not space, loop
	jr 		nz,__PGLoadBuffer

__PGReadWord:			
	ld 		a,EOS 									; put EOS marker on string.
	ld 		(de),a	
	ld 		(PARSEPointer),hl 						; update parse pointer.							
	ld 		hl,PARSEBuffer 							; HL points to buffer
	xor 	a 										; clear carry.
	pop 	de
	pop 	bc
	ret

__PGFail:											; no word available.
	ld 		(PARSEPointer),hl 						; update parse pointer.							
	ld 		hl,$0000 								; return zero.
	scf 											; set carry
	pop 	de
	pop 	bc
	ret
