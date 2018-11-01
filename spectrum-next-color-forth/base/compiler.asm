; ********************************************************************************************************
; ********************************************************************************************************
;
;		Name : 		compiler.asm
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose : 	core assembly file
;		Date : 		6th September 2018
;
; ********************************************************************************************************
; ********************************************************************************************************

; ********************************************************************************************************
;									Compile Block from HL to DE
; ********************************************************************************************************

compileBlock:
		ld 		(bufferPtr),hl 						; save start and end
		ld 		(bufferEnd),de 
w1:
		call 	cbGetWord 							; extract a word.
		ret 	c
		jr 		w1
		ret

; ********************************************************************************************************
;								Extract a word, CS if none, CC if found
; ********************************************************************************************************

cbGetWord:
		call 	cbGetChar 							; get character
		ret 	c 									; end of buffer, return.
		ld 		c,a 								; put in C
		and 	$3F 								; check if space
		cp 		$20
		jr 		z,cbGetWord 						; if space, keep getting, if not first char in C

		ld 		b,0 								; B is count of characters
		ld 		hl,wordBuffer 						; HL is where it goes
__cbGWNext:
		inc 	b 									; inc count and pointer
		inc 	hl
		ld 		(hl),c 								; save word
		call 	cbGetChar 							; get the next character
		jr 		c,__cbGWExit 						; if end of buffer, word fetch complete
		ld 		c,a 								; save in C
		and 	$3F 								; go back if not space to get whole word
		cp 		$20
		jr 		nz,__cbGWNext
__cbGWExit:
		ld 		hl,wordBuffer 						; HL points to word buffer
		ld 		(hl),b 								; write length in there
		ret

;
;		Get character from buffer to A, CS if reached the buffer end.
;
cbGetChar:
		push 	de
		push 	hl
		ld 		hl,(bufferPtr) 						; get current and end
		ld 		de,(bufferEnd)

		ld 		a,l 								; check reached the end
		cp 		e		
		jr 		nz,__cbCharAvailable
		ld 		a,h
		cp 		d
		jr 		nz,__cbCharAvailable

		scf 										; if no characters, return with CS
		pop 	hl
		pop 	de
		ret

__cbCharAvailable:
		xor 	a 									; clear carry flag.
		ld 		a,(hl)								; get character
		inc 	hl 									; bump and write pointer
		ld 		(bufferPtr),hl
		pop 	hl
		pop 	de
		ret

wordBuffer:											; buffer for read word
		ds 		34
bufferPtr: 											; pointer into buffer being scanned
		dw 		0
bufferEnd: 											; end of buffer being scanned
		dw 		0

// TODO: 
//		 Code to convert to decimal and binary.
// 		 Do definitions
// 		 Do compiles
//		 Do executes

