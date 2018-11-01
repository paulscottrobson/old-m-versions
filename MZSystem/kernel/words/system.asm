; ***********************************************************************************************
; ***********************************************************************************************
;
;		Name : 		system.asm
;		Purpose : 	System words
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	5th October 2018
;
; ***********************************************************************************************
; ***********************************************************************************************

; ***********************************************************************************************
;						sys.info 	Get System Information address
; ***********************************************************************************************

; @@word 		sys.info
		ex 		de,hl
		ld 		hl,SystemInformation
		ret

; ***********************************************************************************************
;				switch and stack new page (can only be used from $8000-$BFFF)
; ***********************************************************************************************

; @@word 		page.switch
		ld 		a,l
		jp 		PAGESwitch

; @@word 		page.restore
		jp 		PAGERestore

; ***********************************************************************************************
;							  large edit buffer information
; ***********************************************************************************************

; @@word 		edit.buffer
		ex 		de,hl
		ld 		hl,EditBuffer
		ret

; @@word 		edit.buffer.size
		ex 		de,hl
		ld 		hl,1024
		ret

; ***********************************************************************************************
;					do.text Do Test from DE->HL return error message or 0 
; ***********************************************************************************************

; @@word 		do.text
		call 	PARSESetBuffer
__doTextLoop:
		call 	PARSENextWord
		jr 		c,__doTextComplete
		call 	PROCProcessWord
		jr 		nc,__doTextLoop
		ld 		hl,ParseBuffer
		push 	hl
__dbAppend:
		inc 	hl
		ld 		a,(hl)
		or 		a
		jr 		nz,__dbAppend
		ld 		(hl),' '
		inc 	hl
		ld 		(hl),'?'
		inc 	hl
		ld 		(hl),'?'
		inc 	hl
		ld 		(hl),0	
		pop 	hl
		ret

__doTextComplete:
		ld 		hl,$0000
		ret

; ***********************************************************************************************
;						save.image  Write image to boot_save.img
; ***********************************************************************************************

; @@word 		save.image.save
		jp 		$7FF9 								; relies on the bootstrap code (!)

