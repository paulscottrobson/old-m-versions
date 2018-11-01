; *********************************************************************************
; *********************************************************************************
;
;		File:		screen_layer2.asm
;		Purpose:	Layer 2 console interface, sprites enabled, no shadow.
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

Layer2Print:
		cp 		12									; is it clear screen (also initialises)
		jr 		nz,L2PrintCharacter

		push 	af
		push 	bc
		push 	de
		db 		$ED,$91,$15,$3						; Disable LowRes band enable Sprites

		ld 		e,2 								; 3 banks to erase
L2PClear:
		ld 		a,e 								; put bank number in bits 6/7
		rrc 	a
		rrc 	a
		or 		2+1 								; shadow on, visible, enable write paging
		ld 		bc,$123B 							; out to layer 2 port
		out 	(bc),a
		ld 		hl,$4000 							; erase the bank to $00
L2PClearBank: 										; assume default palette :)
		dec 	hl
		ld 		(hl),$00
		ld 		a,h
		or 		l
		jr		nz,L2PClearBank
		dec 	e
		jp 		p,L2PClear


		pop 	de
		pop 	bc
		pop 	af
		ld 		hl,$1820 							; still 32 x 24
		ret

L2PrintCharacter:
		push 	af
		push 	bc
		push 	de
		push 	hl
		push 	ix

		push 	af
		xor 	a 									; convert colour in C to palette index
		bit 	0,c 								; (assumes standard palette)
		jr 		z,__L2Not1
		or 		$03
__L2Not1:
		bit 	2,c
		jr 		z,__L2Not2
		or 		$1C
__L2Not2:
		bit 	1,c
		jr 		z,__L2Not3
		or 		$C0
__L2Not3:
		ld 		c,a 								; C is foreground
		ld 		b,0									; B is background

		pop 	af 									; restore char
		bit 	7,a 								; adjust background bit on bit 7
		jr 		z,__L2NotCursor
		ld 		b,$49*2 							; light grey is cursor
__L2NotCursor:
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
		;	calculate X * 8 + Y * 8 * 256
		;
		ex 		de,hl 								; coordinates in HL
		add 	hl,hl 								; multiply by 8 keeping overflow
		add 	hl,hl
		add 	hl,hl

		push 	bc
		ld 		a,h
		and 	$C0
		or 		2+1 								; shadow on, visible, enable write paging
		ld 		bc,$123B 							; out to layer 2 port
		out 	(bc),a
		pop 	bc

		ld 		a,h 								; force into range $0000-$3FFF
		and 	$3F
		ld 		h,a

		ld 		e,8 								; do 8 rows
__L2Outer:
		push 	hl 									; save start
		ld 		d,8 								; do 8 columns
		ld 		a,(ix+0) 							; get the bit pattern
		inc 	ix
__L2Loop:
		ld 		(hl),b 								; background
		add 	a,a 								; shift pattern left
		jr 		nc,__L2NotSet
		ld 		(hl),c 								; if MSB was set, overwrite with fgr
__L2NotSet:
		inc 	hl
		dec 	d 									; do a row
		jr 		nz,	__L2Loop
		pop 	hl 									; restore, go 256 bytes down.
		inc 	h
		dec 	e 									; do 8 rows
		jr 		nz,__L2Outer

		pop 	ix
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

