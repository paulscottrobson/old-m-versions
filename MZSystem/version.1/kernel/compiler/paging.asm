; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		paging.asm
;		Purpose : 	Paging code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	30th September 2018
;
; ***********************************************************************************************
; ***********************************************************************************************


; ***********************************************************************************************
;
;							Switch page to A, return old page in A
;
; ***********************************************************************************************

PAGESet:
		push 	bc
		push 	de
		ld 		bc,$243B 							; TB Register select
		ld 		d,$56 								; $56 is paging register $C000-$DFFF
		out 	(c),d
		ld 		bc,$253B 							; TB Register access
		in 		e,(c) 								; read old page into E

		nextreg	$56,a 								; Page in the new page at $C000-$DFFF
		inc 	a
		nextreg $57,a 								; and into $E000-$FFFF
		dec 	a
		ex 		af,af'  							; update A'

		ld 		a,e 								; get old page into A
		pop 	de 									; restore registers and exit.
		pop 	bc
		ret

; ***********************************************************************************************
;
;							Compile HL as instruction, 1 or 2 byte.
;
; ***********************************************************************************************

PAGECompileInstruction:
		ld 		a,h
		or 		a
		jr 		z,__PAGECILowOnly
		ld 		a,h
		call	PageCompileByte	
__PAGECILowOnly:	
		ld 		a,l
		call 	PAGECompileByte
		ret

; ***********************************************************************************************
;
;								Compile HL as address/constant Low Hi
;
; ***********************************************************************************************

PAGECompileWord:
		ld 		a,l
		call 	PAGECompileByte
		ld 		a,h
		jr 		PAGECompileByte

; ***********************************************************************************************
;
;											Compile A as a byte
;
; ***********************************************************************************************

PAGECompileByte:
		push 	de
		push 	hl
		ld 		e,a
		ld 		hl,(CodeAddress)
		ld 		a,h
		cp 		$C0
		jr 		nc,__PAGECBIsPagedMemory

		ld 		(hl),e
		inc 	hl
		ld 		(CodeAddress),hl
		pop 	hl
		pop 	de
		ret
		
__PAGECBIsPagedMemory:
		ld 		a,(CodePage)
		call 	PAGESet
		ld 		hl,(CodeAddress)
		ld 		(hl),e
		inc 	hl
		ld 		(CodeAddress),hl
		call 	PAGESet
		pop 	hl
		pop 	de
		ret

; ***********************************************************************************************
;
;									Compile call to CHL from page B
;
;	A page switch is done if:
;		(i) calling from $0000-$BFFF to $C000-$FFFF in any page.
;		(i) calling from $C000-$CFFF to $C000-$FFFF in a different page
;
; ***********************************************************************************************

PAGECompileCall:
		ld 		a,h 								; is the target < $C000
		cp 		$C0
		jr 		c,__PAGECCBasic 					; if so, can just use normal call.

		ld 		a,(CodeAddress+1) 					; if in coded memory, is being called from < $C000
		cp 		$C0
		jr 		c,__PAGESwitchCall

		ld 		a,b 								; different pages.
		cp 		c 									
		jr 		nz,__PAGESwitchCall 				; yes, then we have to perform a long call.
__PAGECCBasic:
		ld 		a,$CD 								; CALL operationcode
		call 	PAGECompileByte
		call 	PAGECompileWord 					; followed by the address
		ret
;
;		We now need to compile code to switch to page C, then call HL.
;
__PAGESwitchCall:
		ld 		a,$01 								; compile LD BC,<address>
		call 	PAGECompileByte
		call 	PAGECompileWord
		ld 		hl,PageSwitchTable
		ld 		de,PageSwitchSecondElement-PageSwitchTable
		ld 		a,c 							
__PAGESwitchCalc:
		cp 		FirstCodePage
		jr		z,__PAGESwitchCalcExit
		add 	hl,de 								; next entry
		dec 	a									; two fewer page table IDs
		dec 	a
		jr 		__PAGESwitchCalc

__PAGESwitchCalcExit:
		ld 		a,$CD 								; compile CALL <PageSwitchHandler<
		call 	PAGECompileByte
		call 	PAGECompileWord
		ret

; ***********************************************************************************************
;
;									Page switch routines.
;
; ***********************************************************************************************

PageSwitch: 	macro 								
		ld 		a,\0 								; A is the page number to switch to.
		nextreg	$57,\0+1 							; switch the $E000-$FFFF to the next page
		jp 		PAGESwitchCommon 					; execute the common code (follows)
endm


PAGESwitchCommon:
		nextreg	$56,a 								; set the $C000-$DFFF page to the macro parameter now in A
		ex 		af,af' 								; get the previous page into A, set the current page in A'
		push 	af 									; save previous page on the stack
		call 	PAGECallBC 							; call the code at BC
		pop 	af 									; get the previous page back off the stack
		nextreg $56,a 								; set the page registers up with that value
		inc 	a
		nextreg	$57,a
		dec 	a 									; A is the value that was popped
		ex 		af,af' 								; and copy the value into A'
		ret 										; and return to caller.

PAGECallBC:	
		push 	bc
		ret

; ***********************************************************************************************
;
;							Table of Page Switch codes, 1 per pair of pages
;
; ***********************************************************************************************


PageSwitchTable:
		PageSwitch 	FirstCodePage+0					; assume $24
PageSwitchSecondElement:
		PageSwitch 	FirstCodePage+2
PageSwitchThirdElement:
		PageSwitch 	FirstCodePage+4
		PageSwitch 	FirstCodePage+6
		PageSwitch 	FirstCodePage+8
		PageSwitch 	FirstCodePage+10
		PageSwitch 	FirstCodePage+12
		PageSwitch 	FirstCodePage+14
		PageSwitch 	FirstCodePage+16 				; page $34 code
		PageSwitch 	FirstCodePage+18
		PageSwitch 	FirstCodePage+20
		PageSwitch 	FirstCodePage+22
		PageSwitch 	FirstCodePage+24
		PageSwitch 	FirstCodePage+26
		PageSwitch 	FirstCodePage+28
		PageSwitch 	FirstCodePage+30
		PageSwitch 	FirstCodePage+32				; page $44 code
		PageSwitch 	FirstCodePage+34
		PageSwitch 	FirstCodePage+36
		PageSwitch 	FirstCodePage+38
		PageSwitch 	FirstCodePage+40
		PageSwitch 	FirstCodePage+42

