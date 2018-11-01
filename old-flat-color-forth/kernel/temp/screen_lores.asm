; *********************************************************************************
; *********************************************************************************
;
;		File:		screen_lores.asm
;		Purpose:	LowRes console interface, sprites enabled.
;		Date:		29th October 2018
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;							Print character or function
; 							===========================
;
;	12 		Initialise, Clear screen, and return sizes (L = XSize,H = YSize)
;   32-127	Print character A at (D,E) in colour C.
;
; *********************************************************************************

LowResPrint:
		cp 		12									; is it clear screen (also initialises)
		jr 		nz,LowPrintCharacter

		push 	af
		push 	bc
		push 	de

		db 		$ED,$91,$15,$83						; Enable LowRes and enable Sprites
		xor 	a 									; layer 2 off.
		ld 		bc,$123B 							; out to layer 2 port
		out 	(bc),a

		ld 		hl,$4000 							; erase the bank to $00
		ld 		de,$6000
LowClearScreen: 									; assume default palette :)
		xor 	a
		ld 		(hl),a
		ld 		(de),a
		inc 	hl
		inc 	de
		ld 		a,h
		cp 		$58
		jr		nz,LowClearScreen
		pop 	de
		pop 	bc
		pop 	af
		ld 		hl,$0C10 							; resolution is 16x12 chars
		ret

LowPrintCharacter:
		push 	af
		push 	bc
		push 	de
		push 	hl
		push 	ix

		push 	af
		ld 		a,c 								; only lower 3 bits of colour
		and 	7
		ld 		c,a 								; C is foreground
		ld 		b,0									; B is background

		pop 	af 									; restore char
		bit 	7,a 								; adjust background bit on bit 7
		jr 		z,__LowNotCursor
		push 	af
		ld 		a,c 								; reverse colours
		xor 	7
		ld 		b,a
		pop 	af
__LowNotCursor:
		and 	$7F 								; offset from space
		sub 	$20
		ld 		l,a 								; put into HL
		ld 		h,0
		add 	hl,hl 								; x 8
		add 	hl,hl
		add 	hl,hl
		push 	hl 									; transfer to IX
		pop 	ix
		push 	bc 									; add the font base to it.
		ld 		bc,(SIFontBase)
		add 	ix,bc
		pop 	bc
		;
		;	calculate X * 8 + Y * 128 * 8
		;
		ld 		a,d 								; remove top/bottom half
		cp 		6
		jr 		c,__LowNotLower
		sub 	6
__LowNotLower:
		ld 		h,a 								; HL = Y * 256
		ld 		l,0
		srl 	h 									; HL = Y * 128
		rr 		l
		ld 		a,e 								; HL = Y * 128 + X
		add 	l 									; add into HL.
		ld 		l,a
		add 	hl,hl 								; multiply by 8
		add 	hl,hl
		add 	hl,hl

		ld 		a,h 								; force into range $4000-$57FF
		and 	$3F
		or 		$40
		ld 		h,a

		ld 		a,d 								; if was rows 6..11
		cp 		6
		jr 		c,__LowNotLower2
		set 	5,h 								; put at $6000-$77FF
__LowNotLower2:
		ld 		e,8 								; do 8 rows
__LowOuter:
		push 	hl 									; save start
		ld 		d,8 								; do 8 columns
		ld 		a,(ix+0) 							; get the bit pattern
		inc 	ix
__LowLoop:
		ld 		(hl),b 								; background
		add 	a,a 								; shift pattern left
		jr 		nc,__LowNotSet
		ld 		(hl),c 								; if MSB was set, overwrite with fgr
__LowNotSet:
		inc 	hl
		dec 	d 									; do a row
		jr 		nz,	__LowLoop
		pop 	hl 									; restore, go 256 bytes down.
		push 	de
		ld 		de,128
		add 	hl,de
		pop 	de
		dec 	e 									; do 8 rows
		jr 		nz,__LowOuter

		pop 	ix
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

