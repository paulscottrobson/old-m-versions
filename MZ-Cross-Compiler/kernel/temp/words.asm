; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		core.asm
;		Purpose : 	Core words
;		Created : 	6th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

__mzdefine_3b_2f_6d:
; @macro ;
    call MacroExpansion
    db end__mzdefine_3b_2f_6d-__mzdefine_3b_2f_6d-4
		ret
; @endm
end__mzdefine_3b_2f_6d:

__mzdefine_2b_2f_6d:
; @macro +
    call MacroExpansion
    db end__mzdefine_2b_2f_6d-__mzdefine_2b_2f_6d-4
		add 	hl,de
; @endm
end__mzdefine_2b_2f_6d:

__mzdefine_2e_68:
; @word .h
		ld 		a,' '
		call 	IOPrintCharacter
		jp 		IOPrintHexWord

__mzdefine_30_3c:
; @word 0<
		bit 	7,h
		ld 		hl,0
		ret 	z
		dec 	hl
		ret

__mzdefine_30_3d:
; @word 0=
		ld 		a,h
		or 		l
		ld 		hl,0
		ret 	nz
		dec 	hl
		ret

__mzdefine_3c:
; @word <
		ld 		a,h
        xor 	d
        jp 		m,__LessSignsDifferent
        push 	de
        ex 		de,hl
        sbc 	hl,de
        pop 	de
        jr 		c,__LessTrue
__LessFalse:
        ld 		hl,$0000
        ret
__LessSignsDifferent:
		bit 	7,d
        jr 		z,__LessFalse
__LessTrue:
        ld 		hl,$FFFF
        ret
__mzdefine_32_2f_2f_6d:
; @macro 2/
    call MacroExpansion
    db end__mzdefine_32_2f_2f_6d-__mzdefine_32_2f_2f_6d-4
		sra 	h
		rr 		l
; @endm
end__mzdefine_32_2f_2f_6d:

__mzdefine_61_62_3e_72_2f_6d:
; @macro ab>r
    call MacroExpansion
    db end__mzdefine_61_62_3e_72_2f_6d-__mzdefine_61_62_3e_72_2f_6d-4
		push 	de
		push 	hl
; @endm
end__mzdefine_61_62_3e_72_2f_6d:

__mzdefine_72_3e_61_62_2f_6d:
; @macro r>ab
    call MacroExpansion
    db end__mzdefine_72_3e_61_62_2f_6d-__mzdefine_72_3e_61_62_2f_6d-4
		pop 	hl
		pop 	de
; @endm
end__mzdefine_72_3e_61_62_2f_6d:

__mzdefine_61_3e_72_2f_6d:
; @macro a>r
    call MacroExpansion
    db end__mzdefine_61_3e_72_2f_6d-__mzdefine_61_3e_72_2f_6d-4
		push 	hl
; @endm
end__mzdefine_61_3e_72_2f_6d:

__mzdefine_62_3e_72_2f_6d:
; @macro b>r
    call MacroExpansion
    db end__mzdefine_62_3e_72_2f_6d-__mzdefine_62_3e_72_2f_6d-4
		push 	de
; @endm
end__mzdefine_62_3e_72_2f_6d:

__mzdefine_72_3e_61_2f_6d:
; @macro r>a
    call MacroExpansion
    db end__mzdefine_72_3e_61_2f_6d-__mzdefine_72_3e_61_2f_6d-4
		pop 	hl
; @endm
end__mzdefine_72_3e_61_2f_6d:

__mzdefine_72_3e_62_2f_6d:
; @macro r>b
    call MacroExpansion
    db end__mzdefine_72_3e_62_2f_6d-__mzdefine_72_3e_62_2f_6d-4
		pop 	de
; @endm
end__mzdefine_72_3e_62_2f_6d:

__mzdefine_63_21_2f_6d:
; @macro c!
    call MacroExpansion
    db end__mzdefine_63_21_2f_6d-__mzdefine_63_21_2f_6d-4
		ld 		(hl),e
; @endm
end__mzdefine_63_21_2f_6d:

__mzdefine_21_2f_6d:
; @macro !
    call MacroExpansion
    db end__mzdefine_21_2f_6d-__mzdefine_21_2f_6d-4
		ld 		(hl),e
		inc 	hl
		ld 		(hl),d
		dec 	hl
; @endm
end__mzdefine_21_2f_6d:

__mzdefine_63_40_2f_6d:
; @macro c@
    call MacroExpansion
    db end__mzdefine_63_40_2f_6d-__mzdefine_63_40_2f_6d-4
		ld 		l,(hl)
		ld 		h,0
; @endm
end__mzdefine_63_40_2f_6d:

__mzdefine_40_2f_6d:
; @macro @
    call MacroExpansion
    db end__mzdefine_40_2f_6d-__mzdefine_40_2f_6d-4
		ld 		a,(hl)
		inc 	hl
		ld 		h,(hl)
		ld 		l,a
; @endm
end__mzdefine_40_2f_6d:

__mzdefine_63_6c_72_2e_73_63_72_65_65_6e:
; @word clr.screen
		jp 		IOClearScreen

__mzdefine_63_75_72_73_6f_72_21:
; @word cursor!
		jp 		IOSetCursor

__mzdefine_64_65_62_75_67:
; @word debug
		jp 		DebugCode

__mzdefine_68_61_6c_74:
; @word halt
		jp 		HaltCode

__mzdefine_69_6e_6b_65_79:
; @word inkey
		call	IOScanKeyboard
		ex 		de,hl
		ld 		l,a
		ld 		h,0
		ret

__mzdefine_6e_61_6e_64:
; @word nand
		ld 		a,h
		and 	d
		cpl
		ld 		h,a
		ld 		a,l
		and 	e
		cpl
		ld 		l,a
		ret

__mzdefine_70_6f_72_74_40:
; @word port@
		ld 		b,h
		ld 		c,l
		in 		l,(c)
		ld 		h,0

__mzdefine_70_6f_72_74_21:
; @word port!
		ld 		b,h
		ld 		c,l
		out 	(c),e

__mzdefine_61_3e_62_2f_6d:
; @macro a>b
    call MacroExpansion
    db end__mzdefine_61_3e_62_2f_6d-__mzdefine_61_3e_62_2f_6d-4
		ld 		d,h
		ld		e,l
; @endm
end__mzdefine_61_3e_62_2f_6d:

__mzdefine_62_3e_61_2f_6d:
; @macro b>a
    call MacroExpansion
    db end__mzdefine_62_3e_61_2f_6d-__mzdefine_62_3e_61_2f_6d-4
		ld 		h,d
		ld		l,e
; @endm
end__mzdefine_62_3e_61_2f_6d:

__mzdefine_73_63_72_65_65_6e_21:
; @word screen!
		ld 		a,e
		jp 		IOWriteCharacter

__mzdefine_73_77_61_70_2f_6d:
; @macro swap
    call MacroExpansion
    db end__mzdefine_73_77_61_70_2f_6d-__mzdefine_73_77_61_70_2f_6d-4
		ex 		de,hl
; @endm
end__mzdefine_73_77_61_70_2f_6d:

__mzdefine_73_79_73_2e_69_6e_66_6f:
; @word sys.info
		ex 		de,hl
		ld 		hl,SystemInformation
		ret

__mzdefine_76_61_6c_69_64_61_74_65:
; @word validate
		ex 		de,hl
		ld 		a,h
		cp 		d
		jr 		nz,__validate_fail
		ld 		a,l
		cp 		e
		jr 		nz,__validate_fail
		ld 		a,' '
		call	IOPrintCharacter
		jp 		IOPrintHexWord
__validate_fail:
		call 	DebugCode
		jp 		HaltCode

__mzdefine_77_6f_72_64_73_69_7a_65_2a_2f_6d:
; @macro wordsize*
    call MacroExpansion
    db end__mzdefine_77_6f_72_64_73_69_7a_65_2a_2f_6d-__mzdefine_77_6f_72_64_73_69_7a_65_2a_2f_6d-4
		add 	hl,hl
; @endm
end__mzdefine_77_6f_72_64_73_69_7a_65_2a_2f_6d:

__mzdefine_2a:
; @word *
		jp	 	MULTMultiply16

__mzdefine_2f:
; @word /
		push 	de
		call 	DIVDivideMod16
		ex 		de,hl
		pop 	de
		ret

__mzdefine_6d_6f_64:
; @word mod
		push 	de
		call 	DIVDivideMod16
		pop 	de
		ret
; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		datatransfer.asm
;		Purpose : 	Copy and Fill routines
;		Date : 		3rd October 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ========================================================================================================
;								Set the count value for data transfer
; ========================================================================================================

__mzdefine_63_6f_75_6e_74_21:
; @word 		count!
		ld 		(DataTransferCount),hl
		ret

; ========================================================================================================
;								Fill [Count] bytes with A starting at B
; ========================================================================================================

__mzdefine_66_69_6c_6c:
; @word 		fill

		ld 		bc,(DataTransferCount)
		ld 		a,b
		or 		c
		ret 	z

		push 	bc
		push 	hl

__fill1:ld 		(hl),e

		inc 	hl
		dec 	bc
		ld 		a,b
		or 		c
		jr 		nz,__fill1

		pop 	hl
		pop 	bc
		ret

; ========================================================================================================
;											Copy [Count] bytes from B to A
; ========================================================================================================

__mzdefine_63_6f_70_79:
; @word 		copy

		push 	bc
		push 	de
		push 	hl

		ld 		bc,(DataTransferCount)
		ld 		a,b 								; exit now if count zero.
		or 		c
		jr 		z,__copyExit

		xor 	a 									; find direction.
		sbc 	hl,de
		ld 		a,h
		add 	hl,de
		bit 	7,a 								; if +ve use LDDR
		jr 		z,__copy2

		ex 		de,hl 								; LDIR etc do (DE) <- (HL)
		ldir
__copyExit:
		pop 	hl
		pop 	de
		pop 	bc
		ret

__copy2:
;		db 		$DD,$01
		add 	hl,bc 								; add length to HL,DE, swap as LDDR does (DE) <- (HL)
		ex 		de,hl
		add 	hl,bc
		dec 	de 									; -1 to point to last byte
		dec 	hl
		lddr
		jr 		__copyExit

; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		paging.asm
;		Purpose : 	Paging code.
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

__mzdefine_70_61_67_65_2e_73_77_69_74_63_68:
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

__mzdefine_70_61_67_65_2e_72_65_73_74_6f_72_65:
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


