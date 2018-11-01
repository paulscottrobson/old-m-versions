; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		compiler.asm
;		Purpose:	Code that kicks off the internal compiler
;		Date:		11th August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

StartCompile:
		ld 		hl,(SINextFreeProgram)				; where we compile to
		ld 		hl,$C000 							; source code pointer
		call 	CompileCode 						; compile it
		ld 		hl,(SIRunTimeAddress) 				; get where to run from and run.
		db 		$DD,$01
		jp 		(hl)

