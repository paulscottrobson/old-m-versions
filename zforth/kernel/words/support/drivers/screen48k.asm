; *********************************************************************************
; *********************************************************************************
;
;		File:		screen48k.asm
;		Purpose:	Hardware interface to Spectrum display, standard but with
;					sprites enabled. 	
;		Date:		29th October 2018
;		Author:		paul@robsons.org.uk
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

ZX48KPrint:
		cp 		12									; is it clear screen (also initialises)
		jr 		nz,ZXWriteCharacter 				; no, it's a character.
		
; *********************************************************************************
;
;								Clear the screen
;
; *********************************************************************************

		push 	af 									; save registers
		push 	bc

		ld 		bc,$123B 							; Layer 2 access port
		ld 		a,0 								; disable Layer 2
		out 	(c),a
		db 		$ED,$91,$15,$3						; Disable LowRes but enable Sprites

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
		xor 	a 									; border off
		out 	($FE),a
		pop 	bc
		pop 	af
		ld 		hl,$1820 							; H = 24,L = 32, screen extent
		ret

; *********************************************************************************
;
;				Write a character A on the screen at H,L, in colour C
;
; *********************************************************************************

ZXWriteCharacter:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl

		push 	de
		push 	af
;
;		work out attribute position
;
		push 	bc
		ld 		l,d 								; for position DE calculate
		ld 		h,0 								; the attribute location.
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		ld 		c,e
		ld 		b,$58
		add 	hl,bc
		pop 	bc

		ld 		a,c 								; get current colour
		and 	7  									; mask 0..2
		or 		$40  								; make bright
		ld 		(hl),a 								; store it.	

		pop 	af 									; get character
		bit 	7,a 								; if no cursor skip
		jr 		z,__ZXWNoCursor
		set 	7,(hl)
__ZXWNoCursor:
;
;		char# 32-127 to font address
;
		and 	$7F 								; bits 0-6 only.
		sub 	32
		ld 		l,a 								; put in HL
		ld 		h,0
		add 	hl,hl 								; x 8
		add 	hl,hl
		add 	hl,hl
		ld 		de,(SIFontBase) 					; add the font base.
		add 	hl,de
		ex 		de,hl 								; put in DE (font address)
;
;		calculate screen position.
;
		pop 	bc
		ld 		a,c 								; lower 5 bits is X position.
		and 	31
		ld 		l,a
		ld 		a,b 								; get Y position
		cp 		24
		jr 		nc,__wcexit
		and 	7
		rrc 	a 									; rotate into bits 5-7
		rrc 	a
		rrc 	a
		or 		l
		ld 		l,a
		ld 		a,b 	
		and 	$18
		or 		$40
		ld 		h,a
;
;		copy font data to screen position.
;
		ld 		b,8 								; copy 8 characters

__ZXWCCopy:
		ld 		a,(de)								; 0
		ld 		(hl),a
		inc 	h
		inc 	de
		djnz 	__ZXWCCopy

__wcexit:
		pop 	hl 									; restore and exit
		pop 	de
		pop 	bc
		pop 	af
		ret
