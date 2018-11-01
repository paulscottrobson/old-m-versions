; ****************************************************************************************
; ****************************************************************************************
;
;		Name:		errors.asm
;		Purpose:	Error reporting.
;		Date:		11th August 2018
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ****************************************************************************************
; ****************************************************************************************

ERR_UnknownWord:							; don't recognise word so can't do anything, word in 

ERR_NoDefName:								; nothing to use as : <name> etc.

ERR_UnclosedComment : 						; (* without *)

error:	jr 	error