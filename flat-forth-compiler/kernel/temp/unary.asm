; *********************************************************************************
; *********************************************************************************
;
;		File:		unary.asm
;		Purpose:	Unary words
;		Created : 	25th October 2018
;
; *********************************************************************************
; *********************************************************************************

; *********************************************************************************
;
;						Simple Adjustments +/- 1 or 2
;
; *********************************************************************************

__forthdefine_31_2b_2f_6d_61_63_72_6f:
; @macro 1+
		inc 	hl
__forthdefine_31_2b_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_32_2b_2f_6d_61_63_72_6f:
; @macro 2+
		inc 	hl
		inc 	hl
__forthdefine_32_2b_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_31_2d_2f_6d_61_63_72_6f:
; @macro 1-
		dec 	hl
__forthdefine_31_2d_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_32_2d_2f_6d_61_63_72_6f:
; @macro 2-
		dec 	hl
		dec 	hl
__forthdefine_32_2d_2f_65_6e_64_6d_61_63_72_6f:
; @endm

; *********************************************************************************
;
;									Left Scalars
;
; *********************************************************************************

__forthdefine_32_2a_2f_6d_61_63_72_6f:
; @macro 2*
		add 	hl,hl
__forthdefine_32_2a_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_34_2a_2f_6d_61_63_72_6f:
; @macro 4*
		add 	hl,hl
		add 	hl,hl
__forthdefine_34_2a_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_38_2a_2f_6d_61_63_72_6f:
; @macro 8*
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
__forthdefine_38_2a_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_31_36_2a_2f_6d_61_63_72_6f:
; @macro 16*
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
		add 	hl,hl
__forthdefine_31_36_2a_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_32_35_36_2a_2f_6d_61_63_72_6f:
; @macro 256*
		ld 		h,l
		ld 		l,0
__forthdefine_32_35_36_2a_2f_65_6e_64_6d_61_63_72_6f:
; @endm

; *********************************************************************************
;
;								Arithmetic right Scalars
;
; *********************************************************************************

__forthdefine_32_2f_2f_6d_61_63_72_6f:
; @macro 2/
		sra 	h
		rr 		l
__forthdefine_32_2f_2f_65_6e_64_6d_61_63_72_6f:
; @endm

__forthdefine_34_2f:
; @word 4/
		sra 	h
		rr 		l
		sra 	h
		rr 		l
		ret

__forthdefine_38_2f:
; @word 8/
		sra 	h
		rr 		l
		sra 	h
		rr 		l
		sra 	h
		rr 		l
		ret

__forthdefine_31_36_2f:
; @word 16/
		sra 	h
		rr 		l
		sra 	h
		rr 		l
		sra 	h
		rr 		l
		ret

__forthdefine_32_35_36_2f:
; @word 256/
		ld 		h,l
		bit 	7,h
		ld 		h,0
		ret 	z
		dec 	h
		ret

; *********************************************************************************
;
;									0<
;
; *********************************************************************************

__forthdefine_30_3c:
; @word 0<
		bit 	7,h
		ld 		hl,0
		ret 	z
		dec 	hl
		ret

; *********************************************************************************
;
;									0=
;
; *********************************************************************************

__forthdefine_30_3d:
; @word 0=
		ld 		a,h
		or 		l
		ld 		hl,0
		ret 	nz
		dec 	hl
		ret

; *********************************************************************************
;
;								   abs
;
; *********************************************************************************

__forthdefine_61_62_73:
; @word abs
		bit 	7,h
		ret 	z 									; return if +ve
													; NOTE: Falls through here.

; *********************************************************************************
;
;								   Negate / 0-
;
; *********************************************************************************

__forthdefine_30_2d:
; @word 0-
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl
		ld		l,a
		inc 	hl
		ret

; *********************************************************************************
;
;								   Binary Not
;
; *********************************************************************************

__forthdefine_6e_6f_74:
; @word not
		ld 		a,h
		cpl
		ld 		h,a
		ld 		a,l
		cpl
		ld		l,a
		ret

; *********************************************************************************
;
;								   Byte Swap
;
; *********************************************************************************

__forthdefine_62_73_77_61_70_2f_6d_61_63_72_6f:
; @macro bswap
		ld 		a,l
		ld 		l,h
		ld 		h,a
__forthdefine_62_73_77_61_70_2f_65_6e_64_6d_61_63_72_6f:
; @endm
