; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		compiler.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	core assembly file
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************


; ********************************************************************************************************
;									Compile Block from HL to DE
; ********************************************************************************************************

CompileBlock:
		ld 		(bufferPtr),hl 						; save start and end
		ld 		(bufferEnd),de 
;
;		Main compilation loop.
;
cbNextWord:
		call 	cbGetWord 							; extract a word.
		ret 	c 									; exit if completed.

		inc 	hl 									; get the first character
		ld 		a,(hl) 								; so we can type the word
		dec 	hl

		;db 		$DD,$01

		and 	$C0 								; isolate the colour bits
		call 	z,DefineNewWord						; $00 define a new word.

													; $40 is an ignored comment
		cp 		$80 		
		call 	z,CompileOneWord					; $80 is a compiler word

		cp 		$C0 								; $C0 is an execute word
		call 	z,ExecuteOneWord
		
		jr 		cbNextWord
