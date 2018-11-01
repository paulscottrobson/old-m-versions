; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary code.
;		Created : 	22nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;							Set Forth/Macro target dictionaries
;
; ***********************************************************************************************

__cfdefine_66_6f_72_74_68:
; @forth forth
DICTSetForthDictionary:
		xor 	a
		ld 		(DICTTarget),a
		ret

__cfdefine_6d_61_63_72_6f:
; @forth macro
DICTSetMacroDictionary:
		ld 		a,$40
		ld 		(DICTTarget),a
		ret

; ***********************************************************************************************
;
;			Add Dictionary Word. Name is ASCIIZ string at HL, uses the current page/pointer
;			values.
;
; ***********************************************************************************************

__cfdefine_64_69_63_74_2e_61_64_64:
; @forth dict.add
;; Add the word pointed to by A into the dictionary, at the current values for next free code page
;; and next free code pointer.

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
		ld 		a,(DICTTarget)						; type ID comes from Forth vs Macro
		ld 		(ix+5),a
		ld 		de,5 								; advance so IX points to the type ID.
		add 	ix,de
		ld 		(DICTLastTypeByte),ix 				; save that address as last set type byte.
		ex 		de,hl 								; put name in DE
		ld 		hl,(SIDictionaryFree) 				; point HL to the offset
		inc 	ix 									; ix = first character (+6)
__DICTAddCopy:
		ld 		a,(de) 								; copy byte over as 6 bit ASCII.
		and 	$3F
		ld 		(ix+0),a
		ld 		a,(de) 								; reget to test for EOS $5E
		inc 	de
		inc 	ix
		inc 	(hl) 								; increment the offset byte.
		cp 		EOS
		jr 		nz,__DICTAddCopy 					; until string is copied over.
		dec 	ix
		ld 		(ix+0),EOS 							; put proper EOS character in
		inc 	ix
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
;			Find word in dictionary. HL points to name, on exit, HL is the address, D the
;			type ID and E the page number with CC if found, CS set and HL=DE=0 if not found.
;			A indicates the value of bit 6 of the type required.
;
; ***********************************************************************************************

__cfdefine_64_69_63_74_2e_66_69_6e_64_2e_66_6f_72_74_68:
; @forth dict.find.forth
;; Find the forth word pointed to by A (ASCIIZ string), on exit A is the address B.High
;; is the type ID and B.Low the page. If not found A and B are both zero.
		ld 		a,$00 								; we want bit 6 clear, executable
		jr 		DICTFind

__cfdefine_64_69_63_74_2e_66_69_6e_64_2e_6d_61_63_72_6f:
; @forth dict.find.macro
;; Find the macro word pointed to by A (ASCIIZ string), on exit A is the address B.High
;; is the type ID and B.Low the page. If not found A and B are both zero.
		ld 		a,$40 								; we want bit 6 clear, executable
		jr 		DICTFind

DICTFind:
		push 	bc 								; save registers - return in DEHL Carry
		push 	ix
		ld 		b,a 							; put bit 6 requirement in B.
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

		ld 		a,(ix+5) 						; get bit 6 of the type byte
		and 	$40
		cp 		b
		jr 		nz,__DICTFindNext

		push 	ix 								; save pointers on stack.
		push 	hl

__DICTFindCheckMatch:
		ld 		a,(ix+6) 						; get character
		xor 	(hl) 							; do they match
		and 	$3F 							; in bits 0-5
		jr 		nz,__DICTFindNoMatch 			; if no, try the next one
		ld 		a,(hl) 							; get character again
		inc 	ix 								; next character
		inc 	hl
		cp 		EOS 							; was the last match EOS
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
		ld 		b,137 							; start value.
__DICTCHLoop:
		ld 		a,(hl)
		cp 		EOS
		jr 		z,__DICTCHExit
		and 	$3F
		add 	a,b
		rrc 	a
		ld 		b,a
		inc 	hl
		jr 		__DICTCHLoop
__DICTCHExit:
		ld 		a,b
		pop 	hl
		pop 	bc
		ret

; ***********************************************************************************************
;
;					Exclusive or A with the type ID of the last entered value
;
; ***********************************************************************************************

__cfdefine_64_69_63_74_2e_78_6f_72_2e_74_79_70_65:
; @forth dict.xor.type
;; exclusive or the type byte of the last created dictionary entry with A.

		ld 		a,l
		jr 		DICTXorType

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

__cfdefine_64_69_63_74_2e_63_72_75_6e_63_68:
; @forth dict.crunch
;; Remove all private entries from the dictionary.

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
