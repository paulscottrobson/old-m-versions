; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		parsing.asm
;		Purpose : 	Parsing code.
;		Created : 	29th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;
;								Reset,parsing pointer (to HL)
;
; ***********************************************************************************************

__zfdefine_70_61_72_73_65_72_2e_73_65_74_75_70:
; @word parser.setup

PARSEReset:
	ld 		(PARSEPointer),hl
	ret

; ***********************************************************************************************
;
;		   Get next word. Returns pointer to word parsed in HL, and CC, or HL = 0 and CS.
;
; ***********************************************************************************************

__zfdefine_70_61_72_73_65_72_2e_67_65_74:
; @word parser.get

PARSEGet:
	push 	bc
	push 	de
	ld 		hl,(PARSEPointer)
__PGSkipSpaces:
	ld 		a,(hl) 									; get first character, save in B
	ld 		b,a
	or 		a
	jr 		z,__PGFail
	inc 	hl 										; bump pointer
	cp 		' ' 									; loop back if space
	jr 		z,__PGSkipSpaces
	ld 		de,PARSEBuffer 							; DE is the buffer.
__PGLoadBuffer:
	ld 		a,b
	ld 		(de),a 									; copy text into buffer
	inc 	de
	ld 		a,(hl) 									; get next character, save in B
	ld 		b,a
	or 		a
	jr 		z,__PGReadWord
	inc 	hl 										; bump pointer.
	cp 		' ' 									; if not space, loop
	jr 		nz,__PGLoadBuffer

__PGReadWord:
	xor 	a 										; put EOS marker on string.
	ld 		(de),a
	ld 		(PARSEPointer),hl 						; update parse pointer.
	ld 		hl,PARSEBuffer 							; HL points to buffer
	xor 	a 										; clear carry.
	pop 	de
	pop 	bc
	ret

__PGFail:											; no word available.
	ld 		(PARSEPointer),hl 						; update parse pointer.
	ld 		hl,$0000 								; return zero.
	scf 											; set carry
	pop 	de
	pop 	bc
	ret

; ***********************************************************************************************
;
;		   			Get next word as above but fail if nothing found
;
; ***********************************************************************************************

__zfdefine_70_61_72_73_65_72_2e_67_65_74_2e_63_68_65_63_6b:
; @word parser.get.check
PARSEGetCheck:
	call 	PARSEGet
	ret 	nc 										; exit if okay
	ld 		hl,__PARSEGCMsg
	jp 		ErrorHandlerHL
__PARSEGCMsg:
	db 		"Word missing in code",0

; ***********************************************************************************************
;
;		   	Get next word as above but fail if nothing foun, then add to dictionary
;
; ***********************************************************************************************

__zfdefine_70_61_72_73_65_72_2e_67_65_74_2e_63_68_65_63_6b_2e_61_64_64:
; @word parser.get.check.add
	call 	PARSEGetCheck
	jp 		DICTAdd
	jp 		ErrorHandlerHL

