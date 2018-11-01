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
;										Reset Paging
;
; ***********************************************************************************************

PAGEReset:
		push 	af
		push 	hl

		ld 		hl,PAGEStack 						; reset the page stack pointer
		ld 		(PAGEStackPointer),hl 
		ld 		a,(SIFirstCodePage) 				; this is the default code page
		nextreg	$56,a 								; set that as the current page
		inc 	a
		nextreg $57,a
		dec 	a
		ex 		af,af' 								; put it in the A' register as 'current page'

		pop 	hl
		pop 	af
		ret		

; ***********************************************************************************************
;
;							Switch page to A and push old page on stack.
;
; ***********************************************************************************************

PAGESwitch:
		push 	af
		push 	bc
		push 	de
		push 	hl

		ld 		bc,$243B 							; TB Register select
		ld 		d,$56 								; $56 is paging register $C000-$DFFF
		out 	(c),d
		ld 		bc,$253B 							; TB Register access
		in 		e,(c) 								; read old page into E

		nextreg	$56,a 								; Page in the new page at $C000-$DFFF
		inc 	a
		nextreg $57,a 								; and into $E000-$FFFF
		dec 	a

		ld 		hl,(PAGEStackPointer)				; push old register on page stack.
		ld 		(hl),e
		inc 	hl
		ld 		(PAGEStackPointer),hl

		ex 		af,af'  							; update A'

		pop 	hl 									; restore registers and exit.
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;							Restore previous page (undoes PAGESwitch)
;
; ***********************************************************************************************

PAGERestore:
		push 	af
		push 	hl

		ld 		hl,(PAGEStackPointer) 				; pop old page register value off stack
		dec 	hl
		ld 		a,(hl)
		ld 		(PAGEStackPointer),hl

		nextreg	$56,a 								; Page in the new page at $C000-$DFFF
		inc 	a
		nextreg $57,a 								; and into $E000-$FFFF
		dec 	a
		ex 		af,af' 								; update A'

		pop 	hl
		pop 	af
		ret		

; ***********************************************************************************************
;
;										Compile far call to CHL
;
; ***********************************************************************************************
		
PAGECompileFarCall:	
		push 	af
		push 	bc
		push 	de
		push 	hl

		ld 		a,$01 								; compile LD BC,<address>
		call 	MEMCompileByte
		call 	MEMCompileWord
		ld 		hl,PageSwitchTable
		ld 		de,PageSwitchSecondElement-PageSwitchTable
		ld 		a,c 							
__PAGESwitchCalc:
		cp 		$20
		jr		z,__PAGESwitchCalcExit
		add 	hl,	de 								; next entry
		dec 	a									; two fewer page table IDs
		dec 	a
		jr 		__PAGESwitchCalc

__PAGESwitchCalcExit:
		ld 		a,$CD 								; compile CALL <PageSwitchHandler<
		call 	MEMCompileByte
		call 	MEMCompileWord

		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

; ***********************************************************************************************
;
;									Page switch routines.
;
; ***********************************************************************************************

PageCall: 	macro 									
		ld 		a,\0 								; A is the page number to switch to.
		nextreg	$57,\0+1 							; switch the $E000-$FFFF to the next page
		jp 		PAGECallCommon 					; execute the common code (follows)
endm

PAGECallCommon:
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
		PageCall 	$20
PageSwitchSecondElement:
		PageCall 	$22
PageSwitchThirdElement:
		PageCall 	$24
		PageCall 	$26
		PageCall 	$28
		PageCall 	$2A
		PageCall 	$2C
		PageCall 	$2E

		PageCall 	$30
		PageCall 	$32
		PageCall 	$34
		PageCall 	$36
		PageCall 	$38
		PageCall 	$3A
		PageCall 	$3C
		PageCall 	$3E

		PageCall 	$40
		PageCall 	$42
		PageCall 	$44
		PageCall 	$46
		PageCall 	$48
		PageCall 	$4A
		PageCall 	$4C
		PageCall 	$4E

