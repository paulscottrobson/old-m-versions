; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		process.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		23rd September 2018
;		Purpose :	Process word in word buffer.
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
; ***************************************************************************************
;
;								Process word in buffer
;
; ***************************************************************************************
; ***************************************************************************************

PRProcessWord:
		push 	af
		ld 		a,(WordBuffer+1) 					; get the first character of the word.
		and 	$C0 								; what colour is it.
		jr 		z,__PRPWIsDefinition 				; $00 is definition
													; $40 is comment, we ignore that.
		cp 		$80 								; $80 is green (compile)
		jp 		z,__PRPWIsCompilation
		cp 		$C0 								; $C0 is execute immediately.
		jr 		z,__PRPWIsExecution
__PRPWExit:
		pop 	af
		ret

; ***************************************************************************************
;
;									Red (defining) word
;
; ***************************************************************************************

__PRPWIsDefinition:
		push	bc 									; save registers
		push 	hl
		ld 		b,$00 								; no flag bits
		ld 		a,(FreeCodePage) 					; set CHL to current code address
		ld 		c,a
		ld 		hl,(FreeCodeAddress)
		call 	DICTCreate 							; create word.
		pop 	hl 									; restore registers
		pop 	bc
		jr  	__PRPWExit 							

; ***************************************************************************************
;
;								   Yellow (executing) word
;
; ***************************************************************************************

__PRPWIsExecution:
		push 	hl

		ld 		c,WordDictionaryPage 				; search word dictionary page ONLY.
		call 	DICTFind 							; for the word in the buffer.
		jr 		nc,__PRPWExecute 					; if found, execute it.

		call 	ATOIConvert 						; attempt to convert to a constant
		jp 		c,PRPWError 						; if it failed, raise an error

		push 	hl
		ld 		hl,(ARegister) 						; copy A -> B
		ld 		(BRegister),hl
		pop 	hl
		ld 		(ARegister),hl 						; save result in A

__PRPWIEExit:
		pop 	hl
		jp 		__PRPWExit

__PRPWExecute:
		call 	PRPWExecuteCHL 						; execute the word at CHL.
		jr 		__PRPWIEExit

; ***************************************************************************************
;
;								   Error in compile/execute
;
; ***************************************************************************************

PRPWError:
		ld 		hl,WordBuffer
		ld 		e,(hl)
		ld 		d,0
		add 	hl,de
		inc 	hl
		ex 		de,hl
		ld 		hl,__PRPWPadding
		ld 		bc,__PRPWPaddingEnd-__PRPWPadding
		ldir
		ld 		hl,WordBuffer+1

PRPWReportError:
		ld 		a,(hl)
		and 	$3F
		or 		$C0
		call 	IOPrintCharacter
		inc 	hl
		ld 		a,(hl)
		or 		a
		jr 		nz,PRPWReportError

__PRPWStop:
		inc 	a
		and 	7
		out 	($FE),a
		jr 		__PRPWStop

__PRPWPadding:
		db 		" UNKNOWN WORD",0
__PRPWPaddingEnd:

; ***************************************************************************************
;
;								   Execute word at CHL
;
; ***************************************************************************************

PRPWExecuteCHL:
		ld 		a,c 								; setup A' for execution and switch page.
		call 	FARSwitchPageToRun
		push 	af 									; save old page
		ld 		de,__PRPWXContinue 					; finally go here
		push 	de 
		push 	hl 									; first go here.
		ld 		hl,(ARegister)
		ld 		de,(BRegister)
		ld 		ix,(CRegister)
		ret 										; to the push HL above, then ret from that to push DE
__PRPWXContinue:
		ld 		(CRegister),ix
		ld 		(BRegister),de
		ld 		(ARegister),hl
		pop 	af 									; get old page
		call 	FARRestorePage 						; restore original page.
		ret

ARegister: 											; register stores when executing words
		dw 		0
BRegister:
		dw 		0
CRegister:
		dw 		0

XDebug:
		ld 		hl,(ARegister)
		ld 		de,(BRegister)
		ld 		ix,(CRegister)
		jp 		DebugShowABC
		
; ***************************************************************************************
;
;									Green (compiling) word
;
; ***************************************************************************************

__PRPWIsCompilation:
		ld 		c,ImmediateDictionaryPage 			; look in the Macros dictionary
		call 	DICTFind
		jr 		nc,__PRPWICExecute 					; if found, execute it

		ld 		c,WordDictionaryPage 				; look in the Word dictionary
		call 	DICTFind
		jr 		nc,__PRPWICCompile 					; if found, compile it.

		call 	ATOIConvert 						; is it a constant ?
		jp 		c,PRPWError 						; erro if so

__PRPWICConstant:
		ld 		a,$EB 								; ex DE,HL
		call 	FMCompileByte
		ld 		a,$21 								; ld HL,xxxx
		call 	FMCompileByte
		call 	FMCompileWord 						; constant value
 __PRPWICExit:
		jp 		__PRPWExit

__PRPWICExecute:
		;db 		$DD,$01
		call 	PRPWExecuteCHL 						; execute the word 
		jr 		__PRPWICExit 						; and exit

__PRPWICCompile:
		bit  	6,b 								; is it a special (variable@ variable! variable&)
		jr 		nz,__PRPWICSpecial
		ld  	a,(FreeCodePage) 					; set current free code page into B
		ld 		b,a
		call 	FARCallCreateCallCode 				; create a call to the routine at CHL
		jr 		__PRPWICExit

__PRPWICSpecial:
		call 	VARCompileSpecial 					; compile the special
		jr 		__PRPWICExit
		