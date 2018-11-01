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

		