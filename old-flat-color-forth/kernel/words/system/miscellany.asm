; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		miscellany.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Miscellany
;		Created : 	22nd October 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;											Halt the CPU
;
; ********************************************************************************************************

; @forth halt
;; stop the program running

		jp 		HaltZ80

; ********************************************************************************************************
;
;							Get address / size of editing buffer
;
; ********************************************************************************************************

; @forth edit.buffer
;; get address of edit buffer
		
		ex 		de,hl
		ld 		hl,EditBuffer
		ret

; @forth edit.buffer.size
;; get size of edit buffer

		ex 		de,hl
		ld 		hl,EditBufferSize
		ret

; ********************************************************************************************************
;
;						 Return address of system information table
;
; ********************************************************************************************************

; @forth sys.info
;; get address of system information table
		ex 		de,hl
		ld 		hl,SystemInformation
		ret

; ********************************************************************************************************
;
;						discard the return stack except for one level
;
; ********************************************************************************************************

; @forth stack.reset
;; reset the stack pointer of the Z80 to its initial value. Forget everything on the 
;; stack.

		pop 	hl 									; so we know where to return to.
		ld 		sp,(SIStack)						; load the stack pointer
		jp 		(hl)								; do the return.

; ********************************************************************************************************
;
;				incomplete branch handler - used for forward branches as a dummy target
;
; ********************************************************************************************************

; @forth incomplete.branch
;; an error routine which handles incomplete branches

		ex 		de,hl
		ld 		hl,__ICBranchError
		ret
__ICBranchError:
		ld 		hl,__ICBranchText
		jp 		ErrorHandlerHL
__ICBranchText:
		db 		"Come across an unclosed branch (if without then ?)",0
		
; ********************************************************************************************************
;
;								Image save routines (rely on bootloader)
;
; ********************************************************************************************************
	
; @forth save
;; save image as boot.img

		jp 		$7FF9
