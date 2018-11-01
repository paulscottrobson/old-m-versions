; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		debug.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Debug routine (shows A B C on bottom line) and Hex Printer
;		Date : 		7th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;									Show A/B/C on the bottom line
;
; ********************************************************************************************************

DebugShowABC:
		push 	bc
		push 	de
		push 	hl
		push 	ix
		push 	de

		ex 		de,hl
		ld 		b,'A'+$40
		ld 		c,$40
		ld 		hl,12+23*32
		call 	__DisplayHexInteger

		pop 	de
		ld 		b,'B'+$40
		ld 		c,$C0
		ld 		hl,19+23*32
		call 	__DisplayHexInteger

		pop 	de
		ld 		b,'C'+$40
		ld 		c,$00
		ld 		hl,26+23*32
		call 	__DisplayHexInteger

		pop 	hl
		pop 	de
		pop 	bc
		ret		

__DisplayHexInteger:
		ld 		a,b
		call 	IOWriteCharacter
		inc 	hl
		ld 		a,':'+$80
		call 	IOWriteCharacter
		inc 	hl
		ld 		a,d
		call 	__DisplayHexByte
		ld 		a,e
__DisplayHexByte:
		push 	af
		rrca
		rrca
		rrca
		rrca
		call	__DisplayHexNibble
		pop 	af
__DisplayHexNibble:
		and 	$0F
		cp 		10
		jr 		c,__DisplayIntCh
		sub 	57
__DisplayIntCh:
		add 	a,48
		or 		c
		call	IOWriteCharacter
		inc 	hl
		ret

; ********************************************************************************************************
;
;										Print HL on console.
;
; ********************************************************************************************************

DebugPrintHLHex:
		ld 		a,' '
		call 	IOPrintCharacter
		ld 		a,h
		call 	__PrintByte
		ld 		a,l
__PrintByte:
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

