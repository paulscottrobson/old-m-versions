; *********************************************************************************
; *********************************************************************************
;
;		File:		hardware.asm
;		Purpose:	Hardware interface to Spectrum
;		Date:		2nd October 2018
;
; *********************************************************************************
; *********************************************************************************

ZXPrint:
		push 	af
		push 	hl
		ld 		hl,(IOCursorPosition)
		call 	ZXWriteCharacter
		inc 	hl
		ld 		a,h
		and 	3
		cp 		3
		jr 		nz,__IOPCNotHome
		ld 		hl,0
__IOPCNotHome:
		call	ZXSetCursor
		pop 	hl
		pop 	af
		ret

; *********************************************************************************
;
;		Set the current display cursor position to the offset specified in
;		the lower 10 bits of HL.
;
; *********************************************************************************

ZXSetCursor:
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

ZXClearScreen:
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
		call 	ZXSetCursor
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

ZXWriteCharacter:
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

