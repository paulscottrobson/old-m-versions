; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		paging.asm
;		Purpose : 	Paging code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;										Reset Paging
;
; ***********************************************************************************************

PAGEReset:
		push 	af
		push 	hl

		ld 		hl,PAGEStack 						; reset the page stack pointer
		ld 		(PAGEStackPointer),hl 
		ld 		a,(SIFirstCodePage) 				; this is the default code page
		nextreg	$56,a 								; set that as the current page
		inc 	a
		nextreg $57,a
		dec 	a
		ex 		af,af' 								; put it in the A' register as 'current page'

		pop 	hl
		pop 	af
		ret		

; ***********************************************************************************************
;
;							Switch page to A and push old page on stack.
;
; ***********************************************************************************************

PAGESwitch:
		push 	af
		push 	bc
		push 	de
		push 	hl

		ld 		bc,$243B 							; TB Register select
		ld 		d,$56 								; $56 is paging register $C000-$DFFF
		out 	(c),d
		ld 		bc,$253B 							; TB Register access
		in 		e,(c) 								; read old page into E

		nextreg	$56,a 								; Page in the new page at $C000-$DFFF
		inc 	a
		nextreg $57,a 								; and into $E000-$FFFF
		dec 	a

		ld 		hl,(PAGEStackPointer)				; push old register on page stack.
		ld 		(hl),e
		inc 	hl
		ld 		(PAGEStackPointer),hl

		ex 		af,af'  							; update A'

		pop 	hl 									; restore registers and exit.
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;							Restore previous page (undoes PAGESwitch)
;
; ***********************************************************************************************

PAGERestore:
		push 	af
		push 	hl

		ld 		hl,(PAGEStackPointer) 				; pop old page register value off stack
		dec 	hl
		ld 		a,(hl)
		ld 		(PAGEStackPointer),hl

		nextreg	$56,a 								; Page in the new page at $C000-$DFFF
		inc 	a
		nextreg $57,a 								; and into $E000-$FFFF
		dec 	a
		ex 		af,af' 								; update A'

		pop 	hl
		pop 	af
		ret		

; ***********************************************************************************************
;
;										Compile far call to CHL
;
; ***********************************************************************************************
		
PAGECompileFarCall:	
		push 	af
		push 	bc
		push 	de
		push 	hl

		ld 		a,$01 								; compile LD BC,<address>
		call 	MEMCompileByte
		call 	MEMCompileWord
		ld 		hl,PageSwitchTable
		ld 		de,PageSwitchSecondElement-PageSwitchTable
		ld 		a,c 							
__PAGESwitchCalc:
		cp 		$20
		jr		z,__PAGESwitchCalcExit
		add 	hl,	de 								; next entry
		dec 	a									; two fewer page table IDs
		dec 	a
		jr 		__PAGESwitchCalc

__PAGESwitchCalcExit:
		ld 		a,$CD 								; compile CALL <PageSwitchHandler<
		call 	MEMCompileByte
		call 	MEMCompileWord

		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;									Page switch routines.
;
; ***********************************************************************************************

PageCall: 	macro 									
		ld 		a,\0 								; A is the page number to switch to.
		nextreg	$57,\0+1 							; switch the $E000-$FFFF to the next page
		jp 		PAGECallCommon 					; execute the common code (follows)
endm

PAGECallCommon:
		nextreg	$56,a 								; set the $C000-$DFFF page to the macro parameter now in A
		ex 		af,af' 								; get the previous page into A, set the current page in A'
		push 	af 									; save previous page on the stack
		call 	PAGECallBC 							; call the code at BC
		pop 	af 									; get the previous page back off the stack
		nextreg $56,a 								; set the page registers up with that value
		inc 	a
		nextreg	$57,a
		dec 	a 									; A is the value that was popped
		ex 		af,af' 								; and copy the value into A'
		ret 										; and return to caller.

PAGECallBC:	
		push 	bc
		ret

; ***********************************************************************************************
;
;							Table of Page Switch codes, 1 per pair of pages
;
; ***********************************************************************************************


PageSwitchTable:
		PageCall 	$20
PageSwitchSecondElement:
		PageCall 	$22
PageSwitchThirdElement:
		PageCall 	$24
		PageCall 	$26
		PageCall 	$28
		PageCall 	$2A
		PageCall 	$2C
		PageCall 	$2E

		PageCall 	$30
		PageCall 	$32
		PageCall 	$34
		PageCall 	$36
		PageCall 	$38
		PageCall 	$3A
		PageCall 	$3C
		PageCall 	$3E

		PageCall 	$40
		PageCall 	$42
		PageCall 	$44
		PageCall 	$46
		PageCall 	$48
		PageCall 	$4A
		PageCall 	$4C
		PageCall 	$4E

; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		parser.asm
;		Purpose : 	Parse text for words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;							Set the range of the text from DE->HL
;
; ***********************************************************************************************

PARSESetBuffer:
		ld 		(PARSECurrent),de
		ld 		(PARSEEnd),hl
		ret

; ***********************************************************************************************
;
;		Read next word into parse buffer. Return CS if failed, CC if succeeded with 
; 		HL pointing to the buffer (ASCIIZ) and E containing the colour.
;
; ***********************************************************************************************

PARSENextWord:
		push 	bc
		ld 		hl,(PARSECurrent)					; HL = nwxt to scan
		ld 		de,(PARSEEnd) 						; DE = limit of scanning.
;
;		Find the first non-space character.
;
__PARSEFind:	
		call 	__PARSEGetCharacter 				; get the next character
		jr 		c,__PARSEExit 						; if non remaining then exit with carry set
		ld 		b,a 								; save in B
		and 	$3F 								; check to see if it is a space
		cp 		$20
		jr 		z,__PARSEFind 						; if so, go round again.

		ld 		a,b 								; retrieve first character
		and 	$C0 								; get the "colour bits" bits 6 and 7
		ld 		(PARSEWordType),a 					; and save in the type variable.
		ld 		a,b 								; retrieve it.
		ld 		bc,PARSEBuffer 						; BC points to the parse buffer
;
;		Copy word in ; BC points to next space in buffer, A is the char just read in.
;
__PARSELoop:
		and 	$3F 								; make it 6 bit ASCII
		xor 	$20 								; make it 7 bit ASCII
		add 	a,$20
		ld 		(bc),a 								; store in the parse buffer
		inc 	bc 									; bump parse buffer pointer.
		call 	__PARSEGetCharacter 				; get the next character.
		jr 		c,__PARSESucceed 					; if none left what we have so far is fine.
		ld 		(bc),a 								; save it here temporarily
		and 	$3F 								; check if it is a space
		cp 		$20
		ld 		a,(bc) 								; restore character, Z set if space.
		jr 		nz,__PARSELoop 						; if not space get another character.
;
;		Successfully found a word
;
__PARSESucceed:		
		xor 	a 									; make it ASCIIZ.
		ld 		(bc),a

		ld 		(PARSECurrent),hl 					; update the current char pointer.

		ld 		hl,PARSEBuffer 						; HL points to ParseBuffer
		ld 		a,(PARSEWordType)					; DE is the word type
		ld 		e,a
		ld 		d,0
		xor 	a 									; return with carry clear == okay.
;
;		Exit the next word parser.
;
__PARSEExit:
		pop 	bc
		ret

;
;		Read the next character into A, if none left return CS.
;
__PARSEGetCharacter:
		ld 		a,l 								; compare DE vs HL
		cp 		e
		jr 		nz,__PARSENotEnd
		ld 		a,h
		cp 		d
		scf  										; set carry flag in case equalled.
		ret 	z 									; DE = HL, end of buffer, exit with CS

__PARSENotEnd:
		ld 		a,(hl)								; get character
		inc 	hl 									; bump pointer
		or 		a 									; this clears the carry flag.
		ret

; *********************************************************************************
; *********************************************************************************
;
;		File:		hardware.asm
;		Purpose:	Hardware interface to Spectrum
;		Date:		2nd October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************
	
; *********************************************************************************
;
;		Set the current display cursor position to the offset specified in
;		the lower 10 bits of HL.
;
; *********************************************************************************

IOSetCursor:
		push 	af									; save registers
		push 	hl
		ld 		hl,(IOCursorPosition)				; remove old cursor
		res 	7,(hl)
		pop 	hl
		push 	hl
		ld 		a,h 								; convert new cursor to attr pos
		and 	03
		cp 		3 									; cursor position out of range
		jr 		z,__scexit							; don't update
		or 		$58
		ld 		h,a
		ld 		(IOCursorPosition),hl
__scexit:		
		ld 		hl,(IOCursorPosition)				; show new cursor
		set 	7,(hl)		
 		pop		hl
		pop 	af
		ret

; *********************************************************************************
;
;								Clear the screen
;
; *********************************************************************************

IOClearScreen:
		push 	af 									; save registers
		push 	hl
		ld 		hl,$4000 							; clear pixel memory
__cs1:	ld 		(hl),0
		inc 	hl
		ld 		a,h
		cp 		$58
		jr 		nz,__cs1
__cs2:	ld 		(hl),$47							; clear attribute memory
		inc 	hl
		ld 		a,h
		cp 		$5B
		jr 		nz,__cs2	
		ld 		hl,$0000	
		call 	IOSetCursor
		xor 	a 									; border off
		out 	($FE),a
		pop 	hl 									; restore and exit.
		pop 	af
		ret

; *********************************************************************************
;
;	Write a character A on the screen at HL. HL is bits 0-9, A is a 2+6 bit
;	colour / character.
;
; *********************************************************************************

IOWriteCharacter:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl

		ld 		c,a 								; save character in C

		ld 		a,h 								; check H in range 0-2
		and 	3
		cp 		3
		jr 		z,__wcexit

		push 	hl 									; save screen address
;
;		update attribute
;
		ld 		a,h 								; convert to attribute position
		and 	3
		or 		$58
		ld 		h,a

		ld 		a,c 								; rotate left twice
		rlca
		rlca
		and 	3 									; now a value 0-3
		add 	a,IOColours & 255 					; add __wc_colours, put in DE
		ld 		e,a
		ld 		a,IOColours / 256
		adc 	a,0
		ld 		d,a
		ld 		a,(de)								; get colours.
		ld 		(hl),a
;
;		char# 0-63 to font address
;
		ld 		a,c 								; A = char#
		and 	$3F 								; bits 0-6 only
		xor 	$20									; make it 7 bit.
		add 	a,$20		
		cp 		'A' 								; make it lower case
		jr 		c,__wc2
		cp 		'Z'+1
		jr 		nc,__wc2
		add 	a,$20
__wc2:
		ld 		l,a 								; put in HL
		ld 		h,0
		add 	hl,hl 								; x 8
		add 	hl,hl
		add 	hl,hl
		ld 		de,$3C00 							; add $3C00
		add 	hl,de
		ex 		de,hl 								; put in DE (font address)
;
;		screen position 0-767 to screen address
;
		pop 	hl 									; restore screen address
		ld 		a,h 								; L contains Y5-Y3,X4-X0. Get H
		and 	3 									; lower 2 bits (Y7,Y6)
		add 	a,a 								; shift left three times
		add 	a,a
		add 	a,a
		or 		$40 								; set bit 6, HL now points to VRAM.		
		ld 		h,a 								; put it back in H.
;
;		copy font data to screen position.
;
;
;		ld 		b,8 								; copy 8 characters

		ld 		a,(de)								; 0
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 1
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 2
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 3
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 4
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 5
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 6
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		a,(de)								; 7
		ld 		(hl),a
		inc 	h
		inc 	de

		ld 		hl,(IOCursorPosition)				; show cursor if we've just overwritten it
		set 	7,(hl)

__wcexit:
		pop 	hl 									; restore and exit
		pop 	de
		pop 	bc
		pop 	af
		ret


;
;		colour bit colours
;
IOColours:
		db 		$42 								; 00 (red)
		db 		$47 								; 01 (white)
		db 		$44 								; 10 (green)
		db 		$46 								; 11 (yellow)

; *********************************************************************************
;
;						Print HL as an ASCIIZ string
;
; *********************************************************************************

IOPrintASCIIZString:
		push 	af
		push 	hl
__IOASCIIZ:
		ld 		a,(hl)
		or 		a
		jr 		z,__IOASCIIExit
		call	IOPrintCharacter
		inc 	hl
		jr 		__IOASCIIZ
__IOASCIIExit:
		pop 	hl
		pop 	af
		ret

; *********************************************************************************
;
;					Print 2+6 at cursor position and bump it
;
; *********************************************************************************
		
IOPrintCharacter:
		push 	af
		push 	hl
		ld 		hl,(IOCursorPosition)
		and 	$3F
		or 		$C0
		call 	IOWriteCharacter
		inc 	hl
		ld 		a,h
		and 	3
		cp 		3
		jr 		nz,__IOPCNotHome
		ld 		hl,0
__IOPCNotHome:
		call	IOSetCursor
		pop 	hl
		pop 	af
		ret

; *********************************************************************************
;
;									Print HL in hexadecimal
;
; *********************************************************************************
		
IOPrintHexWord:
		push 	af
		ld 		a,h
		call 	IOPrintHexByte
		ld 		a,l
		call 	IOPrintHexByte
		pop 	af
		ret

; *********************************************************************************
;
;								Print A in hexadecimal
;
; *********************************************************************************
		
IOPrintHexByte:
		push 	af
		rrc 	a
		rrc 	a
		rrc 	a
		rrc 	a
		call 	__PrintNibble
		pop 	af
__PrintNibble:
		and 	15
		cp 		10
		jr 		c,__PNIsDigit
		sub 	48+9
__PNIsDigit:
		add 	48+$40
		jp 		IOPrintCharacter

; *********************************************************************************
;
;			Scan the keyboard, return currently pressed key code in A
;
; *********************************************************************************

IOScanKeyboard:
		push 	bc
		push 	de
		push 	hl

		ld 		hl,__kr_no_shift_table 				; firstly identify shift state.

		ld 		c,$FE 								; check CAPS SHIFT (emulator : left shift)
		ld 		b,$FE
		in 		a,(c)
		bit 	0,a
		jr 		nz,__kr1
		ld 		hl,__kr_shift_table
		jr 		__kr2
__kr1:
		ld 		b,$7F 								; check SYMBOL SHIFT (emulator : right shift)
		in 		a,(c)
		bit 	1,a
		jr 		nz,__kr2
		ld 		hl,__kr_symbol_shift_table
__kr2:

		ld 		e,$FE 								; scan pattern.
__kr3:	ld 		a,e 								; work out the mask, so we don't detect shift keys
		ld 		d,$1E 								; $FE row, don't check the least significant bit.
		cp 		$FE
		jr 		z,___kr4
		ld 		d,$01D 								; $7F row, don't check the 2nd least significant bit
		cp 		$7F
		jr 		z,___kr4
		ld 		d,$01F 								; check all bits.
___kr4:
		ld 		b,e 								; scan the keyboard
		ld 		c,$FE
		in 		a,(c)
		cpl 										; make that active high.
		and 	d  									; and with check value.
		jr 		nz,__kr_keypressed 					; exit loop if key pressed.

		inc 	hl 									; next set of keyboard characters
		inc 	hl
		inc 	hl
		inc 	hl
		inc 	hl

		ld 		a,e 								; get pattern
		add 	a,a 								; shift left
		or 		1 									; set bit 1.
		ld 		e,a

		cp 		$FF 								; finished when all 1's.
		jr 		nz,__kr3 
		xor 	a
		jr 		__kr_exit 							; no key found, return with zero.
;
__kr_keypressed:
		inc 	hl  								; shift right until carry set
		rra
		jr 		nc,__kr_keypressed
		dec 	hl 									; undo the last inc hl
		ld 		a,(hl) 								; get the character number.
__kr_exit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

; *********************************************************************************
;	 						Keyboard Mapping Tables
; *********************************************************************************
;
;	$FEFE-$7FFE scan, bit 0-4, active low
;
;	8:Backspace 13:Return 16:19 colours 0-3 20-23:Left Down Up Right 
;	27:Break 32-95: Std ASCII
;
__kr_no_shift_table:
		db 		0,  'Z','X','C','V',			'A','S','D','F','G'
		db 		'Q','W','E','R','T',			'1','2','3','4','5'
		db 		'0','9','8','7','6',			'P','O','I','U','Y'
		db 		13, 'L','K','J','H',			' ', 0, 'M','N','B'

__kr_symbol_shift_table:
		db 		 0, ':', 0,  '?','/',			'~','|','\','{','}'
		db 		 0,  0,  0  ,'<','>',			'!','@','#','$','%'
		db 		'_',')','(',"'",'&',			'"',';', 0, ']','['
		db 		13, '=','+','-','^',			' ', 0, '.',',','*'

__kr_shift_table:
		db 		0,  ':',0  ,'?','/',			'~','|','\','{','}'
		db 		0,  0,  0  ,'<','>',			16, 17, 18, 19, 20
		db 		8, ')',23,  22, 21,				'"',';', 0, ']','['
		db 		27, '=','+','-','^',			' ', 0, '.',',','*'
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

; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		constant.asm
;		Purpose : 	Constant conversion (ASCIIZ -> HL)
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;				Convert ASCIIZ string at HL to constant at HL ; CS if error
;
; ***********************************************************************************************

CONSTConvert:

		push 	bc
		push 	de
		
		ex 		de,hl 								; pointer in DE
		ld 		hl,$0000 							; current result in HL.
__CONSTLoop:
		ld 		a,(de)								; look at character
		or 		a 									; check if zero
		jr 		z,__CONSTExit 						; if so exit with Carry Clear and result in HL

		ld 		b,h 								; HL -> BC
		ld 		c,l
		add 	hl,hl 								; HL x 4
		add 	hl,hl		
		add 	hl,bc 								; HL x 5
		add 	hl,hl 								; HL x 10

		ld 		a,(de) 								; next character
		and 	$7F 								; make 6 bit
		cp 		'0' 								; check in range
		jr 		c,__CONSTFail 						; failed
		cp 		'9'+1 								
		jr 		nc,__CONSTFail
		and 	15 									; put in BC
		ld 		c,a
		ld 		b,0
		add 	hl,bc
		inc 	de 									; go to next.
		jr 		__CONSTLoop

		xor 	a 									; done it, so clear carry
		jr 		__CONSTExit 						; and exit with HL having the answer

__CONSTFail:
		scf
		ld 		hl,$0000
__CONSTExit:
		pop 	de
		pop 	bc
		ret; *********************************************************************************
; *********************************************************************************
;
;		File:		multiply.asm
;		Purpose:	16 bit unsigned multiply
;		Date:		2nd October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;								Does HL = HL * DE
;
; *********************************************************************************

MULTMultiply16:
		push 	bc
		push 	de
		ld 		b,h 							; get multipliers in DE/BC
		ld 		c,l
		ld 		hl,0 							; zero total
__Core__Mult_Loop:
		bit 	0,c 							; lsb of shifter is non-zero
		jr 		z,__Core__Mult_Shift
		add 	hl,de 							; add adder to total
__Core__Mult_Shift:
		srl 	b 								; shift BC right.
		rr 		c
		ex 		de,hl 							; shift DE left
		add 	hl,hl
		ex 		de,hl
		ld 		a,b 							; loop back if BC is nonzero
		or 		c
		jr 		nz,__Core__Mult_Loop
		pop 	de
		pop 	bc
		ret

		; *********************************************************************************
; *********************************************************************************
;
;		File:		divide.asm
;		Purpose:	16 bit unsigned divide
;		Date:		2nd October 2018
;		Author:		paul@robsons.org.uk
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;			Calculates DE / HL. On exit DE = result, HL = remainder
;
; *********************************************************************************

DIVDivideMod16:

	push 	bc
	ld 		b,d 				; DE 
	ld 		c,e
	ex 		de,hl
	ld 		hl,0
	ld 		a,b
	ld 		b,8
Div16_Loop1:
	rla
	adc 	hl,hl
	sbc 	hl,de
	jr 		nc,Div16_NoAdd1
	add 	hl,de
Div16_NoAdd1:
	djnz 	Div16_Loop1
	rla
	cpl
	ld 		b,a
	ld 		a,c
	ld 		c,b
	ld 		b,8
Div16_Loop2:
	rla
	adc 	hl,hl
	sbc 	hl,de
	jr 		nc,Div16_NoAdd2
	add 	hl,de
Div16_NoAdd2:
	djnz 	Div16_Loop2
	rla
	cpl
	ld 		d,c
	ld 		e,a
	pop 	bc
	ret
	
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

; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		memory.asm
;		Purpose : 	Memory R/W, Compiler R/W
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

MEMCompileInstruction:
		ld 		a,h
		or 		a
		call 	nz,MEMCompileByte
		ld 		a,l
		call 	MEMCompileByte
		ret

MEMCompileWord:
		ld 		a,l
		call 	MEMCompileByte
		ld 		a,h
		call 	MEMCompileByte
		ret

MEMCompileByte:
		push 	af
		push 	de
		push 	hl
		ld 		hl,(SICodeFree)
		ld 		e,a
		ld 		a,h
		cp 		$C0
		jr 		nc,__MEMCBPaged
		ld 		(hl),e
__MEMCBExit:
		inc 	hl
		ld 		(SICodeFree),hl
		pop 	hl
		pop 	de
		pop 	af
		ret

__MEMCBPaged:
		ld 		a,(SICodePage)
		call 	PAGESwitch
		ld 		(hl),e
		call 	PAGERestore
		jr 		__MEMCBExit; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		process.asm
;		Purpose : 	Processes Red, White, Green and Yellow words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			Process word. Word is an ASCIIZ string at HL. E is the colour. CS if error.
;
; ***********************************************************************************************

PROCProcessWord:
		push 	bc
		push 	de
		push 	hl

		ld 		a,e 								; dispatch on colour
		or 		a
		jr 		z,__PROCRedDefiningWord				; $00 red
		cp 		$80
		jr 		z,__PROCGreenDefiningWord 			; $80 green
		cp 		$C0
		jr 		z,__PROCYellowDefiningWord 			; $C0 yellow

													; $40 white just falls through, its a comment

__PROCExitOkay:
		xor 	a 									; clear carry flag.
__PROCExitWithCarry:
		pop 	hl
		pop 	de
		pop 	bc
		ret

; ==================================================================================================
;
;								Red defining word, name in HL
;
; ==================================================================================================


__PROCRedDefiningWord:
		call 	DICTAddWord 						; add word to dictionary.
		jr 		__PROCExitOkay

; ==================================================================================================
;
;								Green compiling word, name in HL
;
; ==================================================================================================

__PROCGreenDefiningWord:
		call 	COMCompile 							; compile that word in code.
		jr 		__PROCExitWithCarry 				; and return whatever carry that was.

; ==================================================================================================
;
;							   Yellow executing word, name in HL
;
; ==================================================================================================

__PROCYellowDefiningWord:
		push 	bc	 								; look up the word only to get the type ID.
		push 	hl
		call 	DICTFindWord
		ld 		a,b
		pop 	hl 	
		pop 	bc
		jr 		c,__PROCYDWNotForbidden 			; if it wasn't found it may be executable (constant)
		bit 	6,a 								; if bit 6 is clear, it is executable
		jr 		z,__PROCYDWNotForbidden
		scf 										; return with CS as cannot execute it.
		jr 		__PROCExitWithCarry

__PROCYDWNotForbidden:
		ld 		de,(SICodeFree) 					; current value where code is being written.
		push 	de 									; save on the stack.
		ld 		de,PROCExecBuffer 					; set to compile into the execute buffer.
		ld 		(SICodeFree),de

		call 	COMCompile 							; compile whatever it was, returning CC if okay
		push 	af 									; save carry flag status
		ld 		a,$C9 								; compile a RET in the buffer.
		call 	MEMCompileByte 
		pop 	af 									; restore Carry Flag status
		pop 	de 									; restore code written address
		ld 		(SICodeFree),de
		jr 		c,__PROCExitWithCarry 				; if carry was set, then you can't run it, return CS

		ld 		hl,(COM_ARegister) 					; run in context.
		ld 		de,(COM_BRegister)
		call 	PROCExecBuffer
		ld 		(COM_ARegister),hl
		ld 		(COM_BRegister),de

		jr 		__PROCExitOkay
; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		loader.asm
;		Purpose : 	Bootstrap code (and others) loader
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;								Bootstrap the whole loader space
;
; ***********************************************************************************************

LOADCode:
		ld 		hl,__LCPrompt
		call 	IOPrintASCIIZString
		ld 		a,(SIFirstBootstrapPage)					; C is the first page pair to load
		ld 		c,a
__LCPageLoop:
		ld 		hl,$C000 									; start downloading pages from $C000
__LCMainLoop:
		ld 		a,'.'
		call 	IOPrintCharacter	
		call 	LCDo1kBlock 								; import a 1k block.	
		ld 		de,1024										; go to next block 
		add 	hl,de
		ld 		a,h
		or 		a
		jr 		nz,__LCMainLoop 							; until done the whole lot.

		ld 		a,(SILastBootstrapPage)						; have we just done the last one.
		cp 		c
		jr 		z,__LCImportDone
		inc 	c 											; do the next one.
		inc 	c
		jr 		__LCPageLoop

__LCImportDone:
		ld 		a,2
		out 	($FE),a
__LCHalt:
		halt
		jr 		__LCHalt

__LCPrompt:
		db 		"BOOT MZ ",0
		
; ***********************************************************************************************
;
;								Upload the 1k block from HL, page C.
;
; ***********************************************************************************************

LCDo1kBlock:
		push 	bc
		push 	de
		push 	hl
		ld 		a,c 										; switch page
		call	PAGESwitch
		ld 		de,EditBuffer 								; copy into the edit buffer.
		ld 		bc,1024
		ldir
		call 	PAGERestore 								; and set it back
		ld 		de,EditBuffer 								; set for parsing.
		ld 		hl,EditBuffer+1024 
		call 	PARSESetBuffer 		
__LCDLoop:
		call 	PARSENextWord 								; get next word
		jr 		c,__LCDExit 								; exit if carry set, e.g. done everything.
		call 	PROCProcessWord 							; process it
		jr 		c,__LCDError
		jr 		__LCDLoop
__LCDExit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

__LCDError:
		ld 		a,'?' 										; display ?
		call 	IOPrintCharacter
		ld 		hl,PARSEBuffer
		call 	IOPrintASCIIZString
__LCDError2: 												; show the fail graphic.
		inc 	a
		and 	7
		out 	($FE),a
		ld 		hl,PARSEBuffer
		jr 		__LCDError2

		; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		data.asm
;		Purpose : 	All Read/Write data in the library mdoules
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************


; ***********************************************************************************************
;
;									System Information Area
;
; ***********************************************************************************************

SystemInformation:

SIDictionaryPage:
		db 		$20,$00 							; +0		Dictionary page.
SIFirstCodePage:
		db 		$24,$00 							; +2 		First code page.
SIDictionaryFree: 
		dw 		$C000 								; +4,+5		Dictionary free pointer (in page)
SICodeFree:					
		dw 		FreeCodeMemory						; +6,+7 	Code free pointer
SICodePage:
		db 		$24,$00 							; +8 		Code free page
SIFirstBootstrapPage:
		db 		$22,$00 							; +10 		First bootstrap page
SILastBootstrapPage:
		db 		$22,$00 							; +12 		Last bootstrap page
SIStackTop:
		dw 		StackInitialValue 					; +14,+15 	Stack initial value
SIRunAddress:
		dw 		LoadCode 							; +16,+17 	Run address
SIRunPage: 										
		db 		$24 								; +18 		Run address page

; ***********************************************************************************************
;
;									Uninitialised Data area
;
; ***********************************************************************************************

PAGEStackPointer:									; paging undo stack pointer
		dw 		0
PAGEStack: 											; paging undo stack.
		dw 		0,0,0,0

PARSECurrent:										; next text to scan
		dw 		0
PARSEEnd: 											; end of text to scan
		dw 		0 
PARSEBuffer:										; buffer for parsed word
		ds 		64 									
PARSEWordType: 										; type of word read in to parse buffer.
		db 		0 									

IOCursorPosition: 									; cursor position in charactes
		dw 		0

DICTLastInformationByte:							; address of last information byte in last created dictionary word
		dw 		0

COM_ARegister: 										; registers used for direct execution.
		dw 		0
COM_BRegister:
		dw 		0

PROCExecBuffer:										; execution space for yellow words
		ds 		32

		dw 		0,0 								; main 1k edit buffer.
EditBuffer:
		ds 		1024
		dw 		0,0

		ds 		128
StackInitialValue:									; Z80 Stack Space
		dw 		0

DataTransferCount:									; used as the count for FILL and COPY which take three parameters
		dw 		0

		
FreeCodeMemory:
