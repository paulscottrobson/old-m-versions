; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		find.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	Find a word in the dictionary.
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;
;				Find word in dictionary. A = 0, find anything, A = 1, find executables only.
;				Return HL = address, CS if not found.
;
; ********************************************************************************************************

FindWord:
		push 	af
		push 	bc
		push 	de
		push 	ix

		ld 		ix,(SVDictionaryBase) 							; we use IX to point to dictionary.
		ld 		c,a 											; save test flag in C
;
;		Check next word in dictionary
;
__FW_Loop:
		ld 		a,(ix+0)										; get offset to next
		or 		a 
		jr 		z,__FW_Fail 									; if zero, we've reached the end so give up.
;
;		Check if we want executables only
;
		ld 		a,c 											; are we checking for executables only.
		cp 		1 
		jr 		nz,__FW_NotExecutablesOnly
		bit 	7,(ix+4) 										; if macro bit is set, don't check this one
		jr 		nz,__FW_NextWord
__FW_NotExecutablesOnly:
;
;		Compare the string at IX+4 and HL to see if they are the same. The dictionary
; 		contains a length prefixed string, except bits 6 and 7 are used for information.
;
		push 	ix 												; save IX+HL, we're going to compare strings
		push 	hl
		ld 		b,(hl)											; number to compare in B.
		inc 	b 												; compare one more, comparing lengths as well

__FW_CompareLoop:
		ld   	a,(ix+4)										; get first character/length
		xor 	(hl) 											; use XOR to compare so we can mask out
		inc 	ix 												; bump character pointers
		inc 	hl
		and 	$3F 											; bits 0..5. If this is zero, it's a match
		jr 		nz,__FW_CompareFail 							; if non-zero the match failed.
		djnz 	__FW_CompareLoop 								; checked length and all characters ?
		jr 		__FW_Found 										; yes, found it.
;
;		Comparison failed ; restore IX and HL and go to the next entry
;
__FW_CompareFail:
		pop 	hl
		pop 	ix
;
__FW_NextWord:
		ld 		e,(ix+0)										; offset to next in DE
		ld 		d,0
		add 	ix,de 											; add the offset
		jr 		__FW_Loop 										; and try again.
;
;		Match successful. Restore IX/HL, copy IX->HL (dictionary entry) and exit with CC
;
__FW_Found:
		pop 	hl 												; restore saved values.
		pop 	ix

		push 	ix 												; put IX -> HL
		pop 	hl

		pop 	ix
		pop 	de
		pop 	bc
		pop 	af
		scf 													; return with carry clear
		ccf
		ret		
;
;		Match failed. Restore registers and exit with CS
;
__FW_Fail:
		pop 	ix
		pop 	de
		pop 	bc
		pop 	af
		scf														; return with Carry Flag set.
		ret


