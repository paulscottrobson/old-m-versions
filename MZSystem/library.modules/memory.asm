; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		memory.asm
;		Purpose : 	Memory R/W, Compiler R/W
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

MEMCompileInstruction:
		ld 		a,h
		or 		a
		call 	nz,MEMCompileByte
		ld 		a,l
		call 	MEMCompileByte
		ret

MEMCompileWord:
		ld 		a,l
		call 	MEMCompileByte
		ld 		a,h
		call 	MEMCompileByte
		ret

MEMCompileByte:
		push 	af
		push 	de
		push 	hl
		ld 		hl,(SICodeFree)
		ld 		e,a
		ld 		a,h
		cp 		$C0
		jr 		nc,__MEMCBPaged
		ld 		(hl),e
__MEMCBExit:
		inc 	hl
		ld 		(SICodeFree),hl
		pop 	hl
		pop 	de
		pop 	af
		ret

__MEMCBPaged:
		ld 		a,(SICodePage)
		call 	PAGESwitch
		ld 		(hl),e
		call 	PAGERestore
		jr 		__MEMCBExit