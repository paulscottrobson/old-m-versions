; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		farmemory.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		23rd September 2018
;		Purpose :	Far Memory and Page access code (not calling)
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								Read word at C:HL to HL
;
; ***************************************************************************************

FMReadWord:
		ld 			a,c
		call 		FARSwitchPage
		push 		af
		ld 			a,(hl)
		inc 		hl
		ld 			h,(hl)
		ld 			l,a
		pop 		af
		call 		FARRestorePage
		ret

; ***************************************************************************************
;
;								Write byte A at C:HL
;
; ***************************************************************************************

FMWriteByte:
		push 		bc
		ld 			b,a
		ld 			a,c
		call 		FARSwitchPage
		ld 			(hl),b 
		call 		FARRestorePage
		pop 		bc
		ret

; ***************************************************************************************
;
;								Write word DE at C:HL
;
; ***************************************************************************************

FMWriteWord:
		push 		af
		ld 			a,c
		call 		FARSwitchPage
		ld 			(hl),e
		inc 		hl
		ld 			(hl),d
		call 		FARRestorePage
		pop 		af
		ret

; ***************************************************************************************
;
;										Compile Byte A
;
; ***************************************************************************************

FMCompileByteL:
		ld 			a,l
FMCompileByte:
		push 		af
		push 		bc
		push 		hl
		ld 			hl,(FreeCodeAddress)
		push 		af
		ld 			a,(FreeCodePage)
		ld 			c,a
		pop 		af
		call 		FMWriteByte
		inc 		hl
		ld 			(FreeCodeAddress),hl
		pop 		hl
		pop 		bc
		pop 		af
		ret		

; ***************************************************************************************
;
;										Compile Word HL
;
; ***************************************************************************************

FMCompileWord:
		push 		af
		ld 			a,l
		call 		FMCompileByte
		ld 			a,h
		call 		FMCompileByte
		pop 		af
		ret

; ***************************************************************************************
;
;	  Compile assembly instruction HL . If H is 0, it's 1 byte, else it's two bytes
;
; ***************************************************************************************
		
FMCompileAssembly:
		ld 			a,h 							; check to see if it is 2 bytes
		or 			a
		jr 			nz,__FMCA2Bytes 				; if so do H L
		ld 			a,l 							; otherwise just do L
		jr 			FMCompileByte
;
__FMCA2Bytes:
		ld 			a,h 							; compile H
		call 		FMCompileByte
		ld 			a,l 							; compile L
		jr 			FMCompileByte

