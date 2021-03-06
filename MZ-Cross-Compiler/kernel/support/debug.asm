; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		debug.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Debug routine (shows A B C on bottom line)
;		Date : 		7th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

DebugCode:	
		push 	bc
		push 	de
		push 	hl

		push 	de

		ex 		de,hl
		ld 		b,'A'+$40
		ld 		c,$40
		ld 		hl,19+23*32
		call 	__DisplayHexInteger

		pop 	de
		ld 		b,'B'+$40
		ld 		c,$C0
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

