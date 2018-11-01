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
		db 		0,  0,  0  ,'<','>',			'!','@','#','$','%'
		db 		8, ')',23,  22, 21,				'"',';', 0, ']','['
		db 		27, '=','+','-','^',			' ', 0, '.',',','*'
