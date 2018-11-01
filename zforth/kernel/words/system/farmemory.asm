; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		farmemory.asm
;		Purpose : 	Far Memory code
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	29th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;								Byte compile far memory A
;
; ***********************************************************************************************

; @word c,

		ld 	a,l
FARCompileByte:
		push 	af 									; save byte and HL
		push 	hl
		push 	af 									; save byte
		ld		a,(SICodeFreePage) 					; switch to page
		call 	PAGESwitch 							; change to current code page.
		ld 		hl,(SICodeFree) 					; write to memory location
		pop 	af
		ld 		(hl),a
		inc 	hl 									; bump memory location
		ld 		(SICodeFree),hl 					; write back
		call 	PAGERestore 						; go back to original page
		pop 	hl 									; restore and exit
		pop 	af
		ret

; ***********************************************************************************************
;
;								Word compile far memory A/HL
;
; ***********************************************************************************************

; @word ,

FARCompileWord:
		push 	af 									; save byte and HL
		push 	de
		push 	hl
		ex 		de,hl 								; word into DE
		ld		a,(SICodeFreePage) 					; switch to page
		call 	PAGESwitch 							; change to current code page.
		ld 		hl,(SICodeFree) 					; write to memory location
		ld 		(hl),e
		inc 	hl 	
		ld 		(hl),d
		inc 	hl
		ld 		(SICodeFree),hl 					; write back
		call 	PAGERestore 						; go back to original page
		pop 	hl
		pop 	de 									; restore and exit
		pop 	af
		ret
		
; ***********************************************************************************************
;
;								  Compile instruction in A
;
; ***********************************************************************************************

; @word i,

		ld 		a,h 								; check for 1 byte opcode
		or 		a
		jr  	z,FAROPCShort
		
		push 	hl 									; compile word with bytes reversed
		ld 		h,l
		ld 		l,a
		call 	FARCompileWord
		pop 	hl
		ret

FAROPCShort: 										; compile byte
		ld 		a,l
		call 	FARCompileByte
		ret

