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
;							Set Forth/Macro target dictionaries
;
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Add Dictionary Word. Name is ASCIIZ string at HL, uses the current page/pointer
;			values.
;
; ***********************************************************************************************

; @word dict.add

DICTAdd:
		push 	af 									; registers to stack.
		push 	bc
		push 	de
		push	hl
		push 	ix
		ld 		a,(SIDictionaryPage)				; switch to dictionary page
		call 	PAGESwitch
		ld 		ix,(SIDictionaryFree)				; IX = Free Dictionary Pointer

		ld 		(ix+0),6 							; offset, update when copying name
		call 	DICTCalculateHash  					; calculate and store hash.
		ld 		(ix+1),a
		ld 		a,(SICodeFreePage)					; code page
		ld 		(ix+2),a
		ld 		de,(SICodeFree)						; code address
		ld 		(ix+3),e
		ld 		(ix+4),d 
		ld 		(ix+5),0 							; initial type ID = 0
		ld 		de,5 								; advance so IX points to the type ID.
		add 	ix,de
		ld 		(DICTLastTypeByte),ix 				; save that address as last set type byte.
		ex 		de,hl 								; put name in DE
		ld 		hl,(SIDictionaryFree) 				; point HL to the offset 
		inc 	ix 									; ix = first character (+6)
__DICTAddCopy:
		ld 		a,(de) 								; copy byte over as 6 bit ASCII.
		ld 		(ix+0),a
		ld 		a,(de) 								; reget to test for
		inc 	de
		inc 	ix 									
		inc 	(hl) 								; increment the offset byte.
		or 		a
		jr 		nz,__DICTAddCopy 					; until string is copied over.

		ld 		(ix+0),0 							; write end of dictionary zero.
		ld 		(SIDictionaryFree),ix 				; update next free pointer.
		call 	PAGERestore
		pop 	ix 									; restore and exit
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;			Find word in dictionary. HL points to name, A & typeID must be zero.
; 			On exit, HL is the address, D the type ID and E the page number with CC 
;			if found, CS set and HL=DE=0 if not found.
;
; ***********************************************************************************************

; @word dict.find
		xor 	a

DICTFind:
		push 	bc 								; save registers - return in DEHL Carry
		push 	ix
		ld 		b,a 							; put bit check in A
		call 	DICTCalculateHash 				; calculate the hash, put in C
		ld 		c,a
		ld 		a,(SIDictionaryPage) 			; switch to dictionary page.
		call 	PAGESwitch
		ld 		ix,$C000 						; dictionary start			
__DICTFindMainLoop:
		ld 		a,(ix+0)						; examine offset, exit if zero.
		or 		a
		jr 		z,__DICTFindFail

		ld 		a,(ix+1) 						; hashes match ?
		cp 		c
		jr 		nz,__DICTFindNext

		ld 		a,(ix+5) 						; mask anything with type ID
		and 	b
		jr 		nz,__DICTFindNext				; if non-zero then not this one.

		push 	ix 								; save pointers on stack.
		push 	hl 

__DICTFindCheckMatch:
		ld 		a,(ix+6) 						; get character
		cp 		(hl) 							; do they match
		jr 		nz,__DICTFindNoMatch 			; if no, try the next one
		inc 	ix 								; next character
		inc 	hl
		or 		a
		jr 		nz,__DICTFindCheckMatch 		; no keep going

		pop 	hl 								; restore HL and IX
		pop 	ix
		ld 		d,(ix+5) 						; D = type
		ld 		e,(ix+2)						; E = page
		ld 		l,(ix+3)						; HL = address
		ld 		h,(ix+4)		
		xor 	a 								; clear the carry flag.
		jr 		__DICTFindExit

__DICTFindNoMatch:								; this one doesn't match.
		pop 	hl 								; restore HL and IX
		pop 	ix
__DICTFindNext:
		ld 		e,(ix+0)						; DE = offset
		ld 		d,$00
		add 	ix,de 							; next word.
		jr 		__DICTFindMainLoop				; and try the next one.

__DICTFindFail:
		ld 		de,$0000 						; return all zeros.
		ld 		hl,$0000
		scf 									; set carry flag
__DICTFindExit:
		push 	af								; restore old page.
		call 	PAGERestore
		pop 	af		
		pop 	ix 								; pop registers and return.
		pop 	bc
		ret

; ***********************************************************************************************
;
;							Calculate word has for ASCIIZ value at HL
;
; ***********************************************************************************************

DICTCalculateHash:
		push 	bc
		push 	hl
		xor 	a
		pop 	hl
		pop 	bc
		ret

; ***********************************************************************************************
;
;					Exclusive or A with the type ID of the last entered value
;
; ***********************************************************************************************

; @word dict.xor.type

		ld 		a,l

DICTXorType:
		push 	af 									; save registers
		push 	hl
		push 	af 									; switch to dictionary preserving A
		ld 		a,(SIDictionaryPage)
		call 	PAGESwitch
		pop 	af
		ld 		hl,(DICTLastTypeByte) 				; XOR with last type byte
		xor 	(hl)
		ld 		(hl),a
		call 	PAGERestore 						; and return to original page
		pop 	hl
		pop 	af
		ret

; ***********************************************************************************************
;
;										Crunch the dictionary
;
; ***********************************************************************************************

; @word dict.crunch

		push	bc
		push 	de
		push 	hl
		push 	ix
		ld 		a,(SIDictionaryPage)				; switch to dictionary page
		call 	PAGESwitch
		ld 		ix,$C000
DICTCrunchLoop:
		ld 		a,(ix+0) 							; get offset
		or 		a
		jr 		z,DICTCrunchExit		
		bit 	7,(ix+5)							; private bit set.
		jr 		z,DICTCrunchNext

		push 	ix 									; DE = address of word
		pop 	de
		ld 		h,0 								; HL = offset to next.
		ld 		l,(ix+0)
		add 	hl,de 								; HL = address of next.

		ld 		a,h 								; BC = ~HL number of bytes to copy.
		cpl
		ld 		b,a
		ld 		a,l
		cpl 	
		ld 		c,a

		ldir 										; copy it
		jr 		DICTCrunchLoop 						; see if the copied over one is private

DICTCrunchNext:
		ld 		e,(ix+0) 							; offset to DE
		ld 		d,0
		add 	ix,de 								; and jump there
		jr 		DICTCrunchLoop

DICTCrunchExit:
		ld 		(SIDictionaryFree),ix 				; update top of dictionary
		ld 		(ix+0),0							; write out the end of dictionary marker.
		call 	PAGERestore 						; restore old page.
		pop 	ix
		pop 	hl
		pop 	de
		pop 	bc
		ret
