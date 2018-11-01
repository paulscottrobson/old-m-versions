; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		dictionary.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd September 2018
;		Purpose :	Dictionary Management
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;	Dictionaries are in pages 32/33 (Executable words) and 34/35 (Macro/Immediate words)
;	They are paged in to $C000 as needed.
;	
;	$C000,$C001 		Next free byte in dictionary (initially 2)
;	$C002 				First entry.
;
;	Entries
;	+0 					Offset to next entry. If zero, then the end has been reached
;	+1 					Hash of dictionary name to speed up looking up.
;	+2,+3 				Address of dictionary object
;	+4 					Page number of dictionary object.
; 	+5 					Flag Byte
;	+6 					Length of dictionary name
; 	+7 					First character of name in 6 bit ASCII
; 	+8 					Second character of name in 6 bit ASCII
;
;	Flag Bits:
;
;	bit 7 				If set, then this word is 'private'
; 	bit 6 				If set, then this word is 'special' (for variables & @ !)
;	bits 5-0 			Currently not used, set to zero.
;
; ***************************************************************************************

; ***************************************************************************************
;
;								Set the current Dictionary
;
; ***************************************************************************************

DICTSetWordDictionary:
		ld 		a,WordDictionaryPage
		ld 		(CurrentDictionary),a
		ret

DICTSetImmediateDictionary:
		ld		a,ImmediateDictionaryPage
		ld 		(CurrentDictionary),a
		ret

; ***************************************************************************************
;
;				Create a dictionary entry in the current dictionary
;
;	Name : 		is in the WordBuffer
;   Address : 	is C (Page) HL (Address)
;	Flag Byte :	is in B
;
; ***************************************************************************************

DICTCreate:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl
		push 	ix

		ld 		a,(CurrentDictionary)				; switch to dictionary
		ld 		(__DICTLastCreatePage),a
		call 	FARSwitchPage
		push 	af									; save restore value on the stack.

		ld 		ix,($C000) 							; this is the next free slot.

		ld 		a,(WordBuffer)						; +0 is the offset, which is the length + 7
		add 	a,7
		ld 		(ix+0),a 							
		call 	__DICTCalculateHash 				; +1 is the hash of the name
		ld 		(ix+1),a
		ld 		(ix+2),l 							; +2,+3 is the address
		ld 		(ix+3),h
		ld 		(ix+4),c 							; +4 is the page #
		ld 		(ix+5),b 							; +5 is the flag byte
		ld 		a,(WordBuffer)						; +6 is the word length
		ld 		(ix+6),a

		ld 		b,a 								; put word length in B
		ld 		de,5 								; advance to flag byte		
		add 	ix,de
		ld 		(__DICTLastFlagByte),ix 			; save its position.
		inc 	ix 									; advance to first chaacter position
		inc 	ix
		ld 		hl,WordBuffer+1 					; copy from the word buffer
__DICTCopyName:
		ld 		a,(hl)								; copy 6 bit ASCII							
		and 	$3F
		xor 	$20									; make it 7 bit, it makes debugging more
		add 	a,$20 								; readable and we only compare 6 bits.
		ld 		(ix+0),a
		inc 	ix 									; bump pointers
		inc 	hl
		djnz 	__DICTCopyName 						; do it the required number of times.

		ld 		(ix+0),0 							; this is the new 'end of dictionary' marker
		ld 		($C000),ix 							; write next free pointer back

		pop 	af									; page dictionary out
		call 	FARRestorePage
		pop 	ix 									; restore and exit.
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

__DICTLastCreatePage:								; page number of last created dictionary item
		db 		$FF
__DICTLastFlagByte:									; address of flag byte, last created dictionary item
		dw 		$4000

; ***************************************************************************************
;
;					Set bits A in the last created dictionary item
;
; ***************************************************************************************

DICTSetLastCreatedFlagBitsL:
		ld 		a,l
DICTSetLastCreatedFlagBits:
		push 	af 									; save registers
		push 	bc
		push 	hl
		ld 		c,a 								; save bits to set in C
		ld 		a,(__DICTLastCreatePage)			; get page#
		call 	FARSwitchPage 						; switch
		ld 		b,a 								; save old page in B
		ld 		hl,(__DICTLastFlagByte) 			; HL is address of flag byte
		ld 		a,c 								; get bits
		or 		(hl)								; or into memory
		ld 		(hl),a
		ld 		a,b 								; restore the page
		call 	FARRestorePage
		pop 	hl
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;				Find a word in the current dictionary
;
;	Name : 		is in the WordBuffer
;	Dictionary to search is in C
;
;   Address : 	is C (Page) HL (Address) returned
;	Flag Byte :	is in B returned
;	Success :	Carry Flag set if failed.
;
; ***************************************************************************************

DICTFind:
		push 	de 									; we preserve DE/IX
		push 	ix
		ld 		a,c
		call 	FARSwitchPage 						; access the dictionary page.
		push 	af

		ld 		hl,$C002 							; HL points to the bottom of the dictionary
		call 	__DICTCalculateHash 				; put the Hash in C
		ld 		c,a

__DICTFindLoop:
		ld 		a,(hl) 								; look at offset to next
		or 		a 									; set Z flag if end of dictionary
		scf 										; set carry flag in case we are done.
		jr 		z,__DICTFindExit 					; if true (end of list) exit with carry flag set.
		inc 	hl 									; look at the hash value
		ld 		a,(hl) 								; read it
		dec 	hl 									; back to start of record
		cp 		c 									; hashes match ?
		jr 		nz,__DICTNext 						; if not, go to next.

		push 	hl 									; IX = HL + 6 (length of name)
		pop 	ix
		ld 		de,6
		add 	ix,de
		ld 		de,WordBuffer 						; DE points to word buffer.
		ld 		b,(ix+0) 							; bytes to match
		inc 	b 									; one more, because we check the length as well
__DICTCheckName:
		ld 		a,(de) 								; XOR the first two bytes. So that we can check 6 bits
		xor 	(ix+0)
		and 	$3F 								; so only checking bits 0..5 match
		jr 		nz,__DICTNext 						; if it fails try the next one.
		inc 	ix 									; bump both pointers
		inc 	de
		djnz 	__DICTCheckName 					; until done length + all characters
		jr 		__DICTFound 						; we are succesful !

__DICTNext:
		ld 		e,(hl) 								; offset into DE
		ld 		d,0
		add 	hl,de 								; point HL to next
		jr 		__DICTFindLoop

__DICTFound:
		push 	hl 									; record in IX
		pop 	ix
		ld 		l,(ix+2)							; read address and page
		ld 		h,(ix+3)
		ld		c,(ix+4) 							; read page and flag byte
		ld 		b,(ix+5) 		
		xor 	a 									; clear the carry for exiting.

__DICTFindExit:
		push 	af 									; save return in DE
		pop 	de
		pop 	af 									; restore AF
		call 	FARRestorePage
		push 	de
		pop 	af 									; restore result
		pop 	ix
		pop 	de
		ret


; ***************************************************************************************
;
;					Calculate search hash of the word in the buffer.
;
;	 If you change this, wordHash() in dictimport.py needs to do the same calculation
;
; ***************************************************************************************

__DICTCalculateHash:
		push 	bc
		push 	hl 
		ld 		hl,WordBuffer 						; HL points to length
		ld 		b,(hl) 								; read into B
		ld 		c,$A7								; hash value initial
__DICTHashLoop:
		inc 	hl 									; point to next character
		rrc 	c 									; rotate C circular
		ld 		a,(hl)								; get character make 6 bit
		and 	$3F
		add 	a,c 								; add to C
		ld 		c,a
		djnz 	__DICTHashLoop
		pop 	hl 									; exit, result is still in A
		pop 	bc
		ret

; ***************************************************************************************
;
;									Crunch both dictionaries
;
; ***************************************************************************************

DICTCrunch:
		ld 		a,WordDictionaryPage 				; do words
		call 	__DICTCrunch
		ld 		a,ImmediateDictionaryPage 			; do immediate/macros
__DICTCrunch:
		call 	FARSwitchPage 						; switch to page
		push 	af
		push 	bc
		push 	de
		push 	hl
		push 	ix
		ld 		ix,$C002 							; start at $C002
__DCLoop:
		ld 		a,(ix+0) 							; read offset.
		or 		a
		jr 		z,__DCExit 							; if zero, exit
		bit 	7,(ix+5) 							; do next if private not set.
		jr 		z,__DCNext
		push 	ix 									; HL (target) = here
		pop 	hl 						
		ld 		e,(ix+0)
		ld 		d,0
		ex 		de,hl
		add 	hl,de 								; DE (target) = here, HL (source) = here + offset
		ld 		a,h 								; BC = 0-source => count
		cpl	
		ld 		b,a
		ld 		a,l
		cpl
		ld 		c,a
		inc 	bc
		ldir
		jr 		__DCLoop 							; and don't advance.

__DCNext:
		ld 		e,(ix+0) 							; DE = offset
		ld 		d,0
		add 	ix,de
		jr 		__DCLoop

__DCExit:
		ld 		($C000),ix 							; fix up new end of dictionary
		pop 	ix
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		call 	FARRestorePage
		ret
