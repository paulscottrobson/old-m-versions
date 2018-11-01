; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		define.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Define new word
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;						Define a new word (HL:Name) in the currently selected dictionary
;
; ********************************************************************************************************

DefineNewWord:
		
		push 	af
		push 	bc
		push 	de
		push 	hl
		push 	ix

		ld 		ix,(SVNextDictionaryFree)  			; the next free space.
		ld 		(LastEntry),ix 						; save last definition made.

		ld 		a,(hl) 								; get length of word
		add 	a,5 								; add 5 for data entries, gives total dictionary entry size
		ld 		(ix+0),a 							; this is the offset

		ld 		de,(SVNextProgramFree) 				; set the code address 
		ld 		(ix+1),e
		ld 		(ix+2),d
		ld 		a,(SVNextProgramFreePage) 			; and the page address
		ld 		(ix+3),a
		ld 		a,(hl) 								; get length into bits 0..5
		ld 		(ix+4),a

		ld 		de,5 								; advance IX to the first character slot.
		add 	ix,de

		ld 		b,(hl) 								; bytes to copy
__dnwCopyName:
		inc 	hl 									; get next character in name
		ld 		a,(hl)
		and 	$3F									; make a 6 bit value
		ld 		(ix+0),a 							; write it out.
		inc 	ix
		djnz 	__dnwCopyName 						; copy the whole name

		ld 		(SVNextDictionaryFree),ix 			; set next dictionary free value
		ld 		(ix + 0),0 							; add the trailing zero marking dictionary end.

		pop 	ix 									; and return.
		pop 	hl
		pop 	de
		pop 	bc
		pop 	af
		ret

LastEntry: 											; last defined word.
		dw 		0
		
; ********************************************************************************************************
;
;						Or Last Entry info/length byte with A
;
; ********************************************************************************************************

SetLastEntryBit:
		push 	af
		push 	bc
		push 	hl
		ld 		b,a 								; save bit in B
		ld 		hl,(LastEntry) 						; get last entry
		ld 		a,h 								; check one has been defined
		or 		l
		jr 		z,__SLENotSet

		inc 	hl 									; if so point to info byte
		inc 	hl
		inc 	hl
		inc 	hl
		ld 		a,(hl) 								; and set that bit
		or 		b
		ld 		(hl),a
		
__SLENotSet:
		pop 	hl
		pop 	bc
		pop 	af
		ret
