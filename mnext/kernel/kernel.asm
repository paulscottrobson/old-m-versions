; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		22nd September 2018
;		Purpose :	Kernel main program
;
; ***************************************************************************************
; ***************************************************************************************

WordDictionaryPage = $20 							; word dictionary here (directly executable)
ImmediateDictionaryPage = $22 						; immediate dictionary here (not directly executable)
FirstCodePage = $24 								; code starts here
FirstCompileOnBootPage = $5E 						; code is loaded from this page to bootstrap
FirstExpandedPage = $60 							; first expanded memory page (e.g. last unexpanded)

		opt 	zxnextreg
		org 	$8000
		jr		Boot
		dw 		0

; ***************************************************************************************
;
;								  System Information Area
;
; ***************************************************************************************

FreeCodeAddress:
		dw 		FreeMemory 							; $8004,5 Address of next free byte
FreeCodePage:
		db 		FirstCodePage						; $8006   Page of next free byte if applicable
CurrentDictionary:
		db 		WordDictionaryPage					; $8007   Page of current dictionary ($20 or $22)
FreeDataAddress: 				
		dw 		FreeData 							; $8008,9 Address of free data area (variables etc.)
BootAddress:
		dw 		StartCompilation 					; $800A,B Address of boot 
BootPage: 
		db  	FirstCodePage						; $800C   Page of boot (if applicable)
FirstCompileCodePage:
		db 		FirstCompileOnBootPage				; $800D   First 16k page for compiling on boot.

; ***************************************************************************************
;
;									Boot the kernel
;
; ***************************************************************************************

Boot:	ld 		sp,StackTop 						; reset the stack
		di 											; disable interrupts
		xor 	a 									; make the border black
		out 	($FE),a
		call 	SwitchFastCPU 						; switch to 14Mhz
		call	IOClearScreen 						; clear the screen
		ld 		hl,BootstrapMsg
__Boot1:ld 		a,(hl)
		and 	$3F
		or 		$C0
		call 	IOPrintCharacter
		inc 	hl
		ld 		a,(hl)
		or 		a
		jr 		nz,__Boot1

		ld 		a,(BootPage) 						; switch to the boot page.
		call 	FARSwitchPageToRun 					; and set up A' 
		
		ld 		hl,(BootAddress)					; and run the word.
		jp 		(hl)

BootstrapMsg:
		db 		"BOOTING ",0

; ***************************************************************************************
;
;									Included Files
;
; ***************************************************************************************

		include "source/paging.asm"					; paging stuff goes here
		include "source/scanner.asm"				; word parser
		include "source/dictionary.asm"				; dictionary manager
		include "source/farmemory.asm"				; far memory routines.
		include "source/atoi.asm"					; convert ASCII to integer
		include "source/block.asm"					; block compiler
		include "source/process.asm" 				; process words (compile etc.)
		include "support/debug.asm"
		include "support/multiply.asm" 				; arithmetic
		include "support/divide.asm"					
		include "support/hardware.asm" 				; screen and keyboard I/O
		include "support/variable.asm"				; variable handler.
		include "support/copyfill.asm" 				; fill and copy

; ***************************************************************************************
;
;					Run the 'compile stored code to boot' routines
;
; ***************************************************************************************

StartCompilation:
		call 	DICTSetWordDictionary 				; switch to word dictionary.
		ld 		a,(FirstCompileCodePage) 			; first page of code
CompileLoop:
		call	BLOCKCompilePage					; compile it
		add 	a,2 								; go to next page
		cp 		FirstExpandedPage 					; until reached end of standard RAM
		jr 		nz,CompileLoop
EndCompilation:										; stop
		ld 		a,1
		out 	($FE),a
		jr 		EndCompilation

; ***************************************************************************************
;
;									Helper functions
;
; ***************************************************************************************

ResetStackPointer:									; resets the stack pointer
		pop 	bc
		ld 		sp,StackTop
		push 	bc
		ret

GetBuffer:											; access buffer address
		ex 		de,hl
		ld 		hl,EditBuffer
		ret
GetBufferSize:										; access buffer size
		ex 		de,hl
		ld 		hl,EditBufferSize
		ret

SwitchFastCPU:										; switch CPU to 14 Mhz
		nextreg 7,2
		ret
		
; ***************************************************************************************
;
;								Free Program Memory Starts Here
;
; ***************************************************************************************

FreeMemory:

; ***************************************************************************************
;
;										Data Allocation
;
; ***************************************************************************************

DataArea = $5B00
StackTop = $5B7E 										; 128 bytes, Z80 stack
WordBuffer = $5B80 										; 64 bytes, Word Buffer
														; (string with a length prefix 2+6 format)
EditBuffer = $5BC8										; editing/compiling buffer (1k long with frame)
EditBufferSize = $0400 									; size of buffer
FreeData = $5FD0 										; data memory here

; ***************************************************************************************
;
;		Bank allocation:
;			$20,$21 		16k Dictionary Space (Words)
;			$22,$23 		16k Dictionary Space (Immediate Words)
; 			$24,$25 		First code bank.
;			$3E,$3F 		Last code bank.
;			$40,$41 		First data bank.
;			$5E,$5F 		Last data bank.			
;
;		Register usage:
;			HL 			A Register
;			DE 			B Register
;			IX 			C Register
;			BC 			Placeholder for far call addresses.
;			A' 			Current page when running code.
;
; ***************************************************************************************
