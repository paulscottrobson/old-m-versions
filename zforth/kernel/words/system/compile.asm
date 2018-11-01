; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		compile.asm
;		Purpose : 	Compiler Code
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	29th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;			In compile mode, switches back to execute. In execute mode, causes error.
;
; ***********************************************************************************************

; @macro execute 
COMSetExecuteMode:
		xor		a
		ld 		(COMIsCompileMode),a
		ret

; ***********************************************************************************************
;
;			In execute mode, switches to compile mode.
;
; ***********************************************************************************************

; @macro compile
		ld 		a,$FF
		ld 		(COMIsCompileMode),a
		ret

; ***********************************************************************************************
;
;			Attempt to define,compile or execute word at HL according to mode set.
;			returns CC/HL=0 if okay, or CS/HL=word on error if cannot figure it out.
;
; ***********************************************************************************************

COMCompileExecute:
		push 	bc 									; save registers
		push 	de
		push 	hl
		ld 		a,(COMIsCompileMode)
		or 		a
		jr 		z,__COMCDoExecute

__COMCDoCompile:
		call 	__COMCompiler
		jr 		__COMCExit
__COMCDoExecute:
		call 	__COMExecutor						; else exceute it
__COMCExit:
		pop 	hl 									; restore registers
		pop 	de
		pop 	bc
		ret 	c 									; if CS return with HL at original value
		ld 		hl,$0000 							; otherwise return zero.
		ret

; ***********************************************************************************************
;
;							Attempt to compile word at HL.
;				returns CC if okay, or CS on error if cannot figure it out.
;
; ***********************************************************************************************

__COMCompiler:
		push 	hl 									; save word address
		xor 	a
		call 	DICTFind							; look up first word in the dictionary.
		jr 		c,__COMCTryConstant

		ld 		a,d 								; look at type ID byte
		and 	7 									; and decide what to do.
		jr 		z,__COMCWord
		cp 		1
		jr 		z,__COMCMacro
		cp 		2
		jr 		z,__COMCAddress
__COMCFail1: 										; shouldn't get here.
		jr 		__COMCFail1

__COMCWord:
		call 	PAGECreateCodeCallEHL 				; compile the code for the word.
		pop 	hl 									; throw away word address
		xor 	a
		ret

__COMCMacro:
		call 	COMExecuteEHL 						; if there, just execute it.
		pop 	hl 									; throw away word address
		xor 	a
		ret

__COMCAddress:
		call 	COMConstantCode 					; if an address, compile as a constant.
		xor 	a
		ret
;
;		If in neither try integer constant.
;
__COMCTryConstant:									; not in either dictionary.
		pop 	hl 									; restore word address
		ld 		a,(hl)								; string constant ?
		and		$3F
		cp 		'"'
		jr 		z,__COMCStringConstant
		call 	CONSTConvert 						; try as an integer constant
		ret 	c 									; error, give up.
		call 	COMConstantCode 					; compile that constant
		xor 	a
		ret
;
;		String Constant
;
__COMCStringConstant:
		push 	hl
		ld 		b,0 								; calculate length
__COMCCalcLength:
		inc 	b
		inc 	hl
		ld 		a,(hl) 	
		or 		a
		jr 		nz,__COMCCalcLength
		ld 		a,$18 								; compile JR
		call 	FARCompileByte
		ld 		a,b 								; length
		call 	FARCompileByte
		ld 		de,(SICodeFree) 					; put address in DE
		pop 	hl 									; now do the string
__COMCCopyString:
		inc 	hl
		ld 		a,(hl)
		or 		a
		jr 		z,__COMCStringDone
		cp 		'_'
		jr 		nz,__COMCNotUnderscore
		ld 		a,' '
__COMCNotUnderscore:
		call 	FARCompileByte
		jr 		__COMCCopyString
__COMCStringDone:
		xor 	a 									; compile end of string
		call 	FARCompileByte
		ex 		de,hl		
		call 	COMConstantCode 					; load in as constant
		xor 	a 									; return with CC
		ret

; ***********************************************************************************************
;
;										Executor for word in HL
;
; ***********************************************************************************************

__COMExecutor:
		push 	hl 									; save word address
		ld 		a,$40 								; find the word, must be executable
		call 	DICTFind 						
		jr 		c,__COMExecNotDictionary 			; skip if not in dictionary.

		ld 		a,d 								; check is it a variable
		and 	7
		cp 		2 									; if so, behave like it's a number.
		jr 		nz,__COMExExecute
		pop 	de 									; throw the value.
		jr 		__COMExHandleConstant

__COMExecNotDictionary:
		pop 	hl 									; restore the name
		call 	CONSTConvert 						; try to make it a number
		ret 	c 									; exit if failed.		
__COMExHandleConstant:
		ld 		de,(COMARegister) 					; copy B to A
		ld 		(COMBRegister),de
		ld 		(COMARegister),hl 					; copy new value to A
		xor 	a 									; ret with CC
		ret

__COMExExecute:
		call 	COMExecuteEHL 						; execute that word in context.
		pop 	hl 									; throw away word address
		xor 	a
		ret

; ***********************************************************************************************
;
;									Generate code for constant in HL
;
; ***********************************************************************************************

COMConstantCode:
		ld 		a,$EB 								; ex de,hl
		call 	FARCompileByte 
		ld 		a,$21 								; ld hl,const
		call 	FARCompileByte
		call 	FARCompileWord 						; compile the constant
		ret

; ***********************************************************************************************
;
;							Execute code at EHL in Register Context
;
; ***********************************************************************************************

COMExecuteEHL:
		ld 		a,e 								; switch to that page
		call 	PAGESwitch
		ld  	bc,__COMExecuteExit   				; push continuation code on the stack
		push 	bc
		push 	hl 									; push call address on stack
		ld 		hl,(COMARegister)
		ld 		de,(COMBRegister)
		ld 		bc,(COMCRegister)
		ret 										; do call address
__COMExecuteExit:
		ld 		(COMARegister),hl
		ld 		(COMBRegister),de
		ld 		(COMCRegister),bc
		call 	PAGERestore 						; restore the page
		ret
