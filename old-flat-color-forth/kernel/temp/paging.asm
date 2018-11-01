; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		paging.asm
;		Purpose : 	Paging code.
;		Created : 	21st October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;								Reset Paging, start at Boot Page.
;
; ***********************************************************************************************

__cfdefine_70_61_67_69_6e_67_2e_72_65_73_65_74:
; @forth paging.reset
PAGEReset:
		push 	af
		push 	hl

		ld 		hl,PAGEStack 						; reset the page stack pointer
		ld 		(PAGEStackPointer),hl
		ld 		a,(SIBootPage) 						; get the boot page.
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

PAGERestore:
		push 	af
		push 	hl

		ld 		hl,(PAGEStackPointer) 				; pop old page register value off stack
		dec 	hl
		ld 		a,(hl)
		ld 		(PAGEStackPointer),hl

		db 		$ED,$92,$56							; Page in the new page at $C000-$DFFF
		inc 	a
		db 		$ED,$92,$57							; and into $E000-$FFFF
		dec 	a
		ex 		af,af' 								; update A'

		pop 	hl
		pop 	af
		ret

; ***********************************************************************************************
;
;					Compile code to call EHL from current compile position
;
;									Note: this is a filler
; ***********************************************************************************************

PAGECreateCodeCallEHL:
		ld 		a,$CD 								; call <Address>
		call 	FARCompileByte
		call 	FARCompileWord 						; compile the constant
		ret
