; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary Functions.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Add Dictionary Word HL (ASCIIZ). The page and address comes from the next
;			free values.
;
; ***********************************************************************************************

DICTAddWord:
		push 	af
		push 	bc
		push 	de
		push 	hl
		push 	ix

		ex 		de,hl 								; name pointer is now in DE

		ld 		a,(SIDictionaryPage)				; switch to dictionary page.
		call 	PAGESwitch

		ld 		ix,(SIDictionaryFree) 				; IX points to current entry.

		ld 		(ix+0),5 							; +0 = offset to next or zero.
		ld 		a,(SICodePage)						; +1 = Code Page
		ld 		(ix+1),a
		ld		hl,(SICodeFree)
		ld 		(ix+2),l 							; +2 = Address of routine (low)
		ld 		(ix+3),h 							; +3 = Address of routine (high)
		ld 		(ix+4),$00 							; +4 = information byte.
													; bits 0-2 type, bit 7 private, bit 6 cannot execute.

		ld 		hl,(SIDictionaryFree)				; HL also to offset, so we can update the offset
		ld 		bc,4 								; point IX to the information byte, DE still points to name.
		add 	ix,bc
		ld 		(DICTLastInformationByte),ix 		; remember the last information byte address
		inc 	ix 									; IX now points to first character
__DICTAWCopyName:
		ld 		a,(de)								; copy character of name
		ld 		(ix+0),a
		inc 	(hl)								; extra one for offsete
		inc 	ix 									; bump pointers.
		inc 	de
		or 		a 									; copied terminating zero ?
		jr 		nz,__DICTAWCopyName

		ld 		(ix+0),$00 							; add the zero as the next offset, ending the list.
		ld 		(SIDictionaryFree),ix 				; write next free pointer
		call 	PAGERestore 						; restore page

		pop 	ix
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;	  Look for word in HL. CS if not found, else CC, with HL = Address, C = Page, B = TypeID
;
; ***********************************************************************************************

DICTFindWord:
		push 	de 								
		push 	ix
		ld 		a,(SIDictionaryPage)				; switch to dictionary page.
		call 	PAGESwitch
		ld 		ix,$C000 							; bottom of list.
__DICTFindLoop:
		ld 		a,(ix+0) 							; look at offset to next
		or 		a 									; if it is zero, we have failed.
		jr 		z,__DICTFailed

		push 	hl 									; save address of name on stack
		ld 		b,h 								; put address of name in BC
		ld 		c,l

		push 	ix 									; ix = start of name in dictionary
		pop 	hl
		ld 		de,5
		add 	hl,de

__DICTCheckName:
		ld 		a,(bc)								; names match ?
		cp 		(hl)
		jr 		nz,__DICTGotoNext 					; if different go to next word to check.
		inc 	bc 									; bump pointers
		inc 	hl
		or 		a 									; until $00 match
		jr 		nz,__DICTCheckName 					; which means we've found a result.
		pop 	hl 									; restore saved name in HL

		ld 		b,(ix+4)							; type ID in B
		ld 		c,(ix+1) 							; page in C
		ld 		l,(ix+2)							; address in HL
		ld 		h,(ix+3)
		or 		a 									; clear carry flag
		jr 		__DICTExit 							; and exit.

__DICTGotoNext:
		pop 	hl 									; restore search name pointer.
		ld 		e,(ix+0)							; offset to next.
		ld 		d,0
		add 	ix,de 								; go to next
		jr 		__DICTFindLoop 						; go check again.

__DICTFailed:
		scf 										; return with CS (and HL = BC = 0 for clarity)
		ld 		hl,$0000
		ld 		bc,$0000
__DICTExit:		
		call 	PAGERestore							; set page back
		pop 	ix
		pop 	de
		ret

; ***********************************************************************************************
;
;								OR the last information byte with A
;
; ***********************************************************************************************

DICTOrInformationByte:
		push 	af
		push 	hl

		push 	af 									; save OR value
		ld 		a,(SIDictionaryPage)				; switch to dictionary page.
		call 	PAGESwitch
		pop 	af 									; get OR value
		ld 		hl,(DICTLastInformationByte)		; address of last info byte in dictionary
		or 		(hl)								; OR value into it
		ld 		(hl),a
		call 	PAGERestore 						; restore page

		pop 	hl
		pop 	af
		ret

; ***********************************************************************************************
;
;							Remove private words from the dictionary
;
; ***********************************************************************************************

DICTCrunchDictionary:
		ld 		a,(SIDictionaryPage)				; switch to dictionary page.
		call 	PAGESwitch
		ld 		ix,$C000 							; base of dictionary.
__DICTCDLoop:
		ld 		a,(ix+0) 							; look at offset
		or 		a 									; if zero, exit
		jr 		z,__DICTCDExit
		bit 	7,(ix+4) 							; is the private bit set ?
		jr 		z,__DICTCDNext 						; if not, go to the next

		ld 		e,ixl 								; put IX -> DE
		ld 		d,ixh
		ld 		l,(ix+0)							; HL = offset to next
		ld 		h,0
		add 	hl,de 								; DE = current, HL = next

		ld 		a,h 								; 0 - next is the number of bytes to copy
		cpl	
		ld 		b,a
		ld 		a,l
		cpl
		ld 		c,a
		ldir 										; copy
		jr 		__DICTCDLoop 						; and check the one you've just copied down.

__DICTCDNext:
		ld 		e,(ix+0) 							; offset into DE
		ld 		d,0
		add 	ix,de
		jr 		__DICTCDLoop 						; and go round again.

__DICTCDExit:
		ld 		(SIDictionaryFree),ix 				; reset the dictionary next free byte value
		call 	PAGERestore 						; restore page
		ret

