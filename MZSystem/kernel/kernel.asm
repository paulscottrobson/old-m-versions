; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		kernel.asm
;		Purpose : 	Kernel Code.
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

		opt 	zxnextreg
		org 	$8000								; start vector (note there is a second in sys.info)
		jp 		Boot
		org 	$8004 								; $8004 contains the address of system.information
		dw 		SystemInformation
Boot:
		ld 		sp,(SIStackTop)						; reset the stack.
		nextreg	7,2 								; next in turbo mode (14Mhz)
		call 	PAGEReset							; reset the paging system
		call	IOClearScreen 						; clear screen home cursor
		ld 		hl,$0000
		call 	IOSetCursor
		ld 		a,(SIRunPage)						; switch to the run page
		call 	PAGESwitch
		ld 		hl,(SIRunAddress)					; this is where we run from.		
		jp 		(hl)

		include 	"temp\words.asm"
		include 	"..\files\library.asm"
