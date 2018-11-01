; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;				Add a dictionary entry. HL points to the name of the entry.
;
; ***********************************************************************************************

DICTAppend:
		push 	af 									; push registers
		push 	bc
		push 	de
		push 	hl
		push 	ix

		ld		a,DictionaryPage 					; access the dictionary page
		call 	PAGESet
		push 	af 									; save old page on stack.
		ex 		de,hl 								; put the pointer to the name in DE.

		ld 		ix,(DictionaryFree) 				; IX is the dictionary free pointer
		ld 		(DICTLastDefinition),ix 			; update last definition pointer

		ld 		(ix+0),5 							; initially the offset is 5 which is the
													; bytes needed without the name.
		ld 		hl,(CodeAddress) 					; put address and page in +1,+2,+3
		ld 		(ix+1),l
		ld 		(ix+2),h
		ld 		a,(CodePage)
		ld 		(ix+3),a
		ld 		(ix+4),0 							; default type is 0.

		ld 		bc,5								; point IX to the first name space.
		add 	ix,bc

		ld 		hl,(DictionaryFree) 				; HL points to offset, update it with name copy

__DICTACopyName:
		ld 		a,(de) 								; copy first character of name
		xor 	$20
		add 	a,$20 								; store in 7 bit ASCII for readability
		ld 		(ix+0),a 	
		inc 	de 									; bump pointers
		inc 	ix
		inc 	(hl) 								; bump offset
		bit 	7,a 								; keep going till bit 7 is set.
		jr 		z,__DICTACopyName

		ld 		(DictionaryFree),ix 				; update dictionary next free pointer
		ld 		(ix+0),0 							; indicates end of dictionary.

		pop 	af 									; get old page
		call 	PAGESet 							; fix it up

		pop 	ix 									; restore registers
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret 										; and exit.

; ***********************************************************************************************
;
;							Or the type ID of the last defined word with L
;
; ***********************************************************************************************

DICTOrLastTypeID:
		push 	af
		push 	hl
		ld		a,DictionaryPage 					; access the dictionary page
		call 	PAGESet
		push 	af 									; save old page on stack.
		ld 		a,l 								; A = new type ID
		ld 		hl,(DICTLastDefinition)				; start of last def
		inc 	hl 									; point to type ID
		inc 	hl
		inc 	hl
		inc 	hl
		or 		(hl) 								; or in bits.
		ld 		(hl),a 								; update the type ID
		pop 	af 									; restore page
		call 	PAGESet
		pop 	hl
		pop 	af
		ret

; ***********************************************************************************************
;
;		Find a dictionary entry. HL points to the name of the entry. On exit, CHL contains
;		the execute address and B the type ID, and Carry Clear, Carry set on Failed.
;
; ***********************************************************************************************

DICTFind:
		push 	de 									; save non return registers
		push 	ix

		ld		a,DictionaryPage 					; access the dictionary page
		call 	PAGESet
		push 	af 									; save old page on stack.

		ld 		ix,$C000 							; start search position.
		ex 		de,hl 								; name pointer now in DE
;
;		FIND Loop, HL = name, IX = current to test.
;
__DICTFindLoop:
		ld 		a,(ix+0) 							; look at offset
		or 		a 									; check if zero
		scf 										; set carry if it is.
		jr 		z,__DICTFindExit

		ld 		h,d 								; name pointer back in HL
		ld  	l,e
		push 	ix 									; save current entry pointer
__DICTCheckName:
		ld 		a,(hl) 								; character from dictionary
		ld 		c,a 								; save in C.
		xor 	(ix+5) 								; compare them using XOR
		and 	$BF 								; throw away bit 6 as we store 7 bit in dictionary
		jr 		nz,__DICTNextEntry 					; if different try next entry.
		inc 	ix
		inc     hl 
		bit 	7,c 								; was bit 7 set, e.g. last character
		jr 		z,__DICTCheckName 					; if not, try the next.

		pop 	ix 									; found a match, restore current entry ptr
		jr 		__DICTFindExit 						; and exit.
;
;		Advance to next
;
__DICTNextEntry:
		pop 	ix 									; restore current entry pointer
		ld 		c,(ix+0)							; BC = offset
		ld 		b,0
		add 	ix,bc 								; go to next
		jr 		__DICTFindLoop 						; and go check that one.

;
;		Exit ; IX points to entry or end ; CS/CC indicates success
;
__DICTFindExit:
		ld 		l,(ix+1) 							; address into HL
		ld 		h,(ix+2) 							; (if error these will be junk)
		ld 		c,(ix+3)							; page into C
		ld 		b,(ix+4) 							; type into B
		
		pop 	de 									; D is old page#
		push 	af 									; save Carry
		ld 		a,d 								; restore old page
		call 	PAGESet
		pop 	af 									; restore Carry
		pop 	ix 									; restore saved registers
		pop 	de
		ret

DICTLastDefinition:
		dw 		0 									; address of last created dictionary entry.
		