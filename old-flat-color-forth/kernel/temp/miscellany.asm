; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		miscellany.asm
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

__cfdefine_68_61_6c_74:
; @forth halt
;; stop the program running

		jp 		HaltZ80

; ********************************************************************************************************
;
;							Get address / size of editing buffer
;
; ********************************************************************************************************

__cfdefine_65_64_69_74_2e_62_75_66_66_65_72:
; @forth edit.buffer
;; get address of edit buffer

		ex 		de,hl
		ld 		hl,EditBuffer
		ret

__cfdefine_65_64_69_74_2e_62_75_66_66_65_72_2e_73_69_7a_65:
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

__cfdefine_73_79_73_2e_69_6e_66_6f:
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

__cfdefine_73_74_61_63_6b_2e_72_65_73_65_74:
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

__cfdefine_69_6e_63_6f_6d_70_6c_65_74_65_2e_62_72_61_6e_63_68:
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

__cfdefine_73_61_76_65:
; @forth save
;; save image as boot.img

		jp 		$7FF9
