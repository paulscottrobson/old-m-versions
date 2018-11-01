; *********************************************************************************
; *********************************************************************************
;
;		File:		ioroutines.asm
;		Purpose:	General I/O Routines.
;		Date:		2nd October 2018
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;							Set Screen Mode
;
; *********************************************************************************

__cfdefine_69_6f_2e_6d_6f_64_65_2e_34_38_6b:
; @forth io.mode.48k
;; standard 48k display

		ld 		bc,ZX48KPrint
__SetMode:
		ld 		(SIScreenManager),bc
		jr 		IOClearScreen

__cfdefine_69_6f_2e_6d_6f_64_65_2e_6c_61_79_65_72_32:
; @forth io.mode.layer2
;; 256x192 Layer 2 colour display

		ld 		bc,Layer2Print
		jr 		__SetMode

__cfdefine_69_6f_2e_6d_6f_64_65_2e_6c_6f_77_72_65_73:
; @forth io.mode.lowres
;; Low resolution 128x96 Colour display

		ld 		bc,LowResPrint
		jr 		__SetMode

; *********************************************************************************
;
;					Interface to the raw console system
;
; *********************************************************************************

__cfdefine_69_6f_2e_72_61_77_2e_63_6c_65_61_72:
; @forth io.raw.clear
;; clear and initialise the screen, setting up the current mode, move the cursor
;; to 0,0 and set the text colour to white.

		jr 		IOClearScreen

__cfdefine_69_6f_2e_72_61_77_2e_63_6f_6c_6f_75_72:
; @forth io.raw.colour
;; set the colour of the text I/O from 0..7, standard Spectrum Colours.

		ld 		a,l
		jr 		IOSetColour

__cfdefine_69_6f_2e_72_61_77_2e_70_72_69_6e_74:
; @forth io.raw.print
;; print character at current cursor position, and move cursor one space to the
;; right. If bit 7 of the character is set it is drawn as with a cursor.

		ld 		a,l
		and 	$7F
		cp 		32
		ret 	c
		ld 		a,l
		jr 		IOPrintChar

__cfdefine_69_6f_2e_72_61_77_2e_6d_6f_76_65:
; @forth io.raw.move
;; set the current cursor position to (B,A).

		push 	hl
		ld 		h,l 							; Y is A.0
		ld 		l,e 							; X is B.0
		call 	IOSetCursor 					; set the cursor
		pop 	hl
		ret

; *********************************************************************************
;
;			Print character at cursor position, cursored if bit 7 set
;
; *********************************************************************************

IOPrintChar:
		push 	af
		push 	bc
		push 	de
		push	hl

		push 	af
		ld 		a,(IOColour)						; colour into C
		ld 		c,a
		ld 		de,(IOCursorX)						; cursor into (D,E_)
		pop 	af
		call 	IODoPrint 							; call print handler

		ld 		a,(SIScreenWidth) 					; screen width in B
		ld 		b,a
		ld 		hl,IOCursorX						; bump cursor x
		inc 	(hl)
		ld 		a,(hl)
		cp 		b
		jr 		c,__IOPrintExit 					; if < width exit.
		xor 	a 									; if so, reset to zero and go one
		ld 		(hl),a 								; further down.

		inc 	hl 									; point to cursor Y
		inc 	(hl) 								; bump cursor Y
		ld 		a,(SIScreenHeight) 					; screen height in B
		ld 		b,a
		ld 		a,(hl)
		cp 		b
		jr 		c,__IOPrintExit 					; if < height exit
		xor 	a 									; back to top.
		ld 		(hl),a
__IOPrintExit:
		pop 	hl 									; exit.
		pop 	de
		pop 	bc
		pop 	af
		ret

IODoPrint:
		ld 		hl,(SIScreenManager)
		jp 		(hl)

; *********************************************************************************
;
;									Set Colour
;
;			0..7 : Black,Blue,Red,Magenta,Green,Cyan,Yellow,White
;
; *********************************************************************************

IOSetColour:
		push 	af
		and 	7
		ld 		(IOColour),a
		pop 	af
		ret

; *********************************************************************************
;
;									Set Cursor
;
; *********************************************************************************

IOSetCursor:
		ld 		(IOCursorX),hl
		ret

; *********************************************************************************
;
;							Raw Clear the screen, Set Mode
;
; *********************************************************************************

IOClearScreen:
		push 	af
		ld 		a,12
		call	IODoPrint
		ld 		a,l
		ld 		(SIScreenWidth),a
		ld 		a,h
		ld 		(SIScreenHeight),a
		ld 		hl,0
		call 	IOSetCursor
		ld 		a,7
		call 	IOSetColour
		pop 	af
		ret

; *********************************************************************************
;
;									Print HL in hexadecimal
;
; *********************************************************************************

__cfdefine_2e_68_65_78:
; @forth .hex
		ld 		a,' '
		call 	IOPrintChar

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
		add 	7
__PNIsDigit:
		add 	48
		jp 		IOPrintChar

; *********************************************************************************
;
;						  Print HL as an ASCIIZ string
;
; *********************************************************************************

IOPrintString:
		push 	af
		push 	hl
__IOASCIIZ:
		ld 		a,(hl)
		or 		a
		jr 		z,__IOASCIIExit
		call	IOPrintChar
		inc 	hl
		jr 		__IOASCIIZ
__IOASCIIExit:
		pop 	hl
		pop 	af
		ret

; *********************************************************************************
;
;					Print A as 2+6 colours, B is the cursor if non-zero
;
; *********************************************************************************

__cfdefine_69_6f_2e_72_61_77_2e_70_72_69_6e_74_2e_32_2b_36:
; @forth io.raw.print.2+6

		push 	bc
		push 	hl
		ld 		a,l
		rlc 	a
		rlc 	a
		and 	3
		ld 		c,a
		ld 		b,0
		ld 		hl,__IORP2Colours
		add 	hl,bc
		ld 		a,(hl)
		call 	IOSetColour
		pop 	hl
		ld 		a,l
		and 	$3F
		xor 	$20
		add 	a,$20
		cp 		'A'
		jr 		c,__IORP2_NotAlpha
		cp 		'Z'+1
		jr 		nc,__IORP2_NotAlpha
		add 	a,$20
__IORP2_NotAlpha:
		ld 		b,a
		ld 		a,d
		or 		e
		jr 		z,__IORP2NoCursor
		;set 	7,b
__IORP2NoCursor:
		ld 		a,b
		call 	IOPrintChar
		pop 	bc
		ret

__IORP2Colours:
		db 		2
		db 		7
		db 		4
		db 		6
