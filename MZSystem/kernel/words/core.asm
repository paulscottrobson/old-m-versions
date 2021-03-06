; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		core.asm
;		Purpose : 	Core words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************
		
; ***********************************************************************************************
;								, 	Compile a Word
; ***********************************************************************************************

; @@word 		,
		jp 		MEMCompileWord

; ***********************************************************************************************
;								c, 	Compile a Byte
; ***********************************************************************************************

; @@word		c,
		ld 		a,l
		jp 		MEMCompileByte

; ***********************************************************************************************
;								i, 	Compile an instruction
; ***********************************************************************************************

; @@word		i,
		jp 		MEMCompileInstruction

; ***********************************************************************************************
;								crunch Remove Private Words
; ***********************************************************************************************

; @@word 		crunch
		jp 		DICTCrunchDictionary
		
; ***********************************************************************************************
;								; 	Return from subroutine
; ***********************************************************************************************

; @@macro.nx	;
		ld 		a,$C9
		jp 		MEMCompileByte

; ***********************************************************************************************
;								.h  Print A
; ***********************************************************************************************

; @@word 		.h
		ld 		a,' '
		call 	IOPrintCharacter
		jp 		IOPrintHexWord

; ***********************************************************************************************
;									Stop the CPU
; ***********************************************************************************************

; @@word 		halt		
HaltSystem:
		di
		halt
		jr 		HaltSystem

; ***********************************************************************************************
;						  Display debug information on bottom line
; ***********************************************************************************************

; @@word 		x.debug
		ld 		hl,(COM_ARegister)
		ld 		de,(COM_BRegister)
; @@word 		debug
		jp 		DebugCode

; ***********************************************************************************************
;								Make the last definition a macro 
; ***********************************************************************************************

; @@macro 		macro
		ld 		a,2
		jp	 	DICTOrInformationByte

; ***********************************************************************************************
;							Make the last definition compile.only
; ***********************************************************************************************

; @@macro 		compile.only
		ld 		a,$40
		jp	 	DICTOrInformationByte

; ***********************************************************************************************
;									Or the type ID with A
; ***********************************************************************************************

; @@word 		or.type.id
		ld 		a,l
		jp	 	DICTOrInformationByte

; *** IMPORTANT *** This is not a macro, it is designed to be used in words that manipulate
; the last definition.

; ***********************************************************************************************
;							   Set cursor position to A
; ***********************************************************************************************

; @@word 		cursor!
		jp 		IOSetCursor

; ***********************************************************************************************
;							  Write B to screen position A
; ***********************************************************************************************

; @@word 		screen!
		ld 		a,e
		jp 		IOWriteCharacter

; ***********************************************************************************************
;							   Clear screen / home cursor
; ***********************************************************************************************

; @@word 		clr.screen
		jp	 	IOClearScreen

; ***********************************************************************************************
;								 Scan the keyboard into A
; ***********************************************************************************************

; @@word 		key@
		call 	IOScanKeyboard
		ld 		l,a
		ld 		h,0
		ret

; ***********************************************************************************************
;										Put B*A in A
; ***********************************************************************************************

; @@word 		*
		jp 		MULTMultiply16

; ***********************************************************************************************
;										Put B/A in A
; ***********************************************************************************************

; @@word 		/
		push 	de
		call	DIVDivideMod16
		ex 		de,hl
		pop 	de
		ret

; ***********************************************************************************************
;									Put Modulus of B/A in A
; ***********************************************************************************************

; @@word 		mod
		push 	de
		call	DIVDivideMod16
		pop 	de
		ret

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
		