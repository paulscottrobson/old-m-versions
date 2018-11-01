; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		paging.asm
;		Purpose : 	Paging code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	6th October 2018
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
		ld 		a,FirstCodePage 					; this is the default code page
		db 		$ED,$92,$56							; set that as the current page
		inc 	a
		db 		$ED,$92,$57
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

; @word 	page.switch

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

		db 		$ED,$92,$56							; Page in the new page at $C000-$DFFF
		inc 	a
		db 		$ED,$92,$57							; and into $E000-$FFFF
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

; @word 	page.restore

PAGERestore:
		push 	af
		push 	hl

		ld 		hl,(PAGEStackPointer) 				; pop old page register value off stack
		dec 	hl
		ld 		a,(hl)
		ld 		(PAGEStackPointer),hl

		db 		$ED,$92,$56							; Page in the new page at $C000-$DFFF
		inc 	a
		db 		$ED,$92,$57 						; and into $E000-$FFFF
		dec 	a
		ex 		af,af' 								; update A'

		pop 	hl
		pop 	af
		ret		

; ***********************************************************************************************
;
;									Page switch routines.
;
; ***********************************************************************************************

PageCall: 	macro basePage									
		ld 		a,&basePage 						; A is the page number to switch to.
		db 		$ED,$91,$57,&basePage+1				; switch the $E000-$FFFF to the next page
		jp 		PAGECallCommon 						; execute the common code (follows)
endm

PAGECallCommon:
		db 		$ED,$92,$56							; set the $C000-$DFFF page to the macro parameter now in A
		ex 		af,af' 								; get the previous page into A, set the current page in A'
		push 	af 									; save previous page on the stack
		call 	PAGECallBC 							; call the code at BC
		pop 	af 									; get the previous page back off the stack
		db 		$ED,$92,$56							; set the page registers up with that value
		inc 	a
		db 		$ED,$92,$57
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


