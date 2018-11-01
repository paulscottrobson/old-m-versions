; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		block.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		23rd September 2018
;		Purpose :	Block Compiler.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								Compile the 16k page in Page A
;
; ***************************************************************************************

BLOCKCompilePage:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl
		ld 		hl,$C000 							; 1k page chunks from $C000 so no huge buffer :)
		push 	af
		ld 		a,7
__BLOCKLoop:
		ld 		a,'.'+$80
		call 	IOPrintCharacter
		pop 	af 									; get page number
		push 	af
		call 	FARSwitchPage 						; map it into $C000
		ld 		de,EditBuffer 						; copy 1k to the edit buffer
		ld 		bc,1024
		ldir
		call 	FARRestorePage 						; restore original page

		call 	BLOCKCompile1kPage 					; compile that page

		ld 		a,h 								; done whole 16k ?
		or 		a
		jr 		nz,__BLOCKLoop

		pop 	af
		pop 	hl									; restore registers
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;					Compile the code in the Edit Buffer, 1k long
;
; ***************************************************************************************

BLOCKCompile1kPage:
		push 	af 									; save registers
		push 	bc
		push 	de
		push 	hl
		ld 		hl,EditBuffer 						; check edit buffer for any non $20 values
		ld 		bc,1024
__BC1kCheckBuffer:
		ld 		a,(hl) 								; check buffer
		and 	$3F
		cp 		$20
		jr 		nz,__BC1kCompile 					; if found a non space, compile the buffer
		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__BC1kCheckBuffer
		jr 		__BC1kExit 							; it's all spaces, so don't do anything.
;
;		There's code in the buffer, compile it.
;
__BC1kCompile:
		ld 		hl,EditBuffer 						; set up for reading words
		ld 		de,EditBuffer+1024
		call 	SCANSetup
__BCCompileLoop:
		call 	SCANGetWord 						; get a word
		jr 		c,__BC1kExit 						; exit if end of 1k block
		call 	PRProcessWord 						; compile, execute, whatever.
		jr 		__BCCompileLoop 					; loop back for next word
;
__BC1kExit:
		pop 	hl 									; restore and exit.
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***************************************************************************************
;
;							Block Compile a chunk of memory (do.source)
;
; ***************************************************************************************

BLOCKCompileMemory:
		CALL 	SCANSetup
__BCMLoop:
		call 	SCANGetWord
		ret 	c
		call 	PRProcessWord
		jr 		__BCMLoop
