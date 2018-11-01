; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		compile.asm
;		Purpose : 	Compiler Code
;		Created : 	22nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

__cfdefine_64_65_6d_6f_6d_61_63_72_6f_2f_6d_61_63_72_6f:
; @macro demomacro
		ld 		a,69
		ret

; ***********************************************************************************************
;
;			Attempt to define,compile or execute word at HL according to mode set.
;			returns CC/HL=0 if okay, or CS/HL=word on error if cannot figure it out.
;
; ***********************************************************************************************

__cfdefine_63_6f_6d_70_69_6c_65_72_2e_64_6f:
; @forth compiler.do
;; compile or execute word at A depending on word colour. If okay, return A = 0, else return A = word

COMCompileExecute:
		push 	bc 									; save registers
		push 	de
		push 	hl
		ld 		a,(hl)								; what colour is the word.
		and 	$C0
		cp 		$40 								; comment
		jr 		z,__COMCExit
		cp 		$80 								; compile word
		jr 		z,__COMCDoCompile
		cp 		$C0 								; execute word
		jr 		z,__COMCDoExecute
		call 	DICTAdd 							; must be add the word into the dictionary.
		xor 	a 									; clear carry
		jr 		__COMCExit

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
;				Attempt to compile or execute word at HL according to mode set.
;				returns CC if okay, or CS on error if cannot figure it out.
;
; ***********************************************************************************************

__COMCompiler:
		push 	hl 									; save word address
;
;		If in compiler dictionary, just call it.
;
		ld 		a,$40 								; look in the compiler dictionary.
		call 	DICTFind
		jr 		c,__COMCTryExecutable
		call 	COMExecuteEHL 						; if there, just execute it.
		pop 	hl 									; throw away word address
		xor 	a
		ret
;
;		If in executable dictionary, compile call to it, or load address
;
__COMCTryExecutable:
		pop 	hl 									; restore word address
		push 	hl
		ld 		a,$00 								; look in the executable dictionary.
		call 	DICTFind
		jr 		c,__COMCTryConstant 				; not found, try constant.
		pop 	bc 									; throw away the word address
		bit 	5,d 								; is it an address ?
		jr 		nz,__COMCAddress
		call 	PAGECreateCodeCallEHL 				; no, a routine, so create a call to it.
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
		cp 		EOS
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
		cp 		EOS
		jr 		z,__COMCStringDone
		and 	$3F
		xor 	$20
		add 	a,$20
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
		xor 	a 									; look for executable words (e.g. bit 6 = 0)
		call 	DICTFind 							; called this.
		jr 		c,__COMExecNotDictionary 			; skip if not in dictionary.
		call 	COMExecuteEHL 						; execute that word in context.
		pop 	hl 									; throw away word address
		xor 	a
		ret
__COMExecNotDictionary:
		pop 	hl 									; restore the name
		call 	CONSTConvert 						; try to make it a number
		ret 	c 									; exit if failed.
		ld 		de,(COMARegister) 					; copy B to A
		ld 		(COMBRegister),de
		ld 		(COMARegister),hl 					; copy new value to A
		xor 	a 									; ret with CC
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
		ret 										; do call address
__COMExecuteExit:
		ld 		(COMARegister),hl
		ld 		(COMBRegister),de
		call 	PAGERestore 						; restore the page
		ret
