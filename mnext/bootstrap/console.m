// ********************************************************************************************************
// ********************************************************************************************************
//
//		Name :		console.m
//		Author :	Paul Robson (paul@robsons.org.uk)
//		Purpose :	Console I/O 
//		Date :		16th September 2018
//
// ********************************************************************************************************
// ********************************************************************************************************

[words]

variable con.position 
variable con.colour
variable con.base

// ************************************************************************************************
//							Number of lines in editing space/screen height
// ************************************************************************************************

:con.edit.size 4 ;											// Number of editing lines
:con.screen.height 24 ;	 									// Total lines

// ************************************************************************************************
//									Clear Screen, Home Cursor
// ************************************************************************************************

:con.clear
	ab>r
	clr.screen 0 con.position! cursor!
	r>ab
;

// ************************************************************************************************
//			   						Emit Raw (e.g. 2+6 bit)
// ************************************************************************************************

:con.rawEmit private
	con.position@ screen!  
	1+ con.position! cursor!
	24 con.edit.size - 16* 2*  
	con.position@ = if con.clear then
;

// ************************************************************************************************
//										Carriage Return
// ************************************************************************************************

:con.cr
	ab>r
	begin 
		$20 con.rawEmit
		con.position@ 31 and 0=
	until
	r>ab
;

// ************************************************************************************************
//										Emit space, spaces
// ************************************************************************************************

:con.space ab>r $20 con.rawEmit r>ab ;					// Print out 1 space
:con.spaces ab>r if for con.space next then r>ab ;		// Print out A spaces

// ************************************************************************************************
//								  Emit (7 bit ASCII, supports CR)
// ************************************************************************************************

:con.emit 
	ab>r 												// Save AB
	$3F and con.colour@ + con.rawEmit 					// colour accordingly
	r>ab 												// Restore AB
;

// ************************************************************************************************
//								  Set colours by number or by name
// ************************************************************************************************

:con.setColour 
	ab>r 3 and 16* 4* con.colour! r>ab 					// store in upper 2 bits of low byte
;

:con.red ab>r 0 con.setColour r>ab ;						// Do direct by colour
:con.white ab>r 1 con.setColour r>ab ;
:con.green ab>r 2 con.setColour r>ab ;
:con.yellow ab>r 3 con.setColour r>ab ;

// ************************************************************************************************
//											Print String
// ************************************************************************************************

:con.print.string 
	ab>r 												// Save on stack
	a>b c@ if 											// Addr in B read length, if non zero
		for swap 1+ a>b c@ con.emit next 				// fetch and print that many times
	then
	r>ab 												// restore
;

// ************************************************************************************************
//											Print Integer
// ************************************************************************************************

:con.print.digit private
 	15 and 10 >= if swap 7 + swap then swap 48 + con.emit 	// Print digit in 0-9a-f fomat
;

:con.print.integer private
	con.base@ ab>r / if con.print.integer then 				// divide by base, recurse if nonzero
	r>ab mod con.print.digit 								// restore, modulus, print digit
;

:con.print.hex
	ab>r 16 con.base! swap con.print.integer r>ab ;
:con.print.dec :.
	ab>r 10 con.base! swap con.print.integer r>ab ;	
:con.print.bin
	ab>r 2 con.base! swap con.print.integer r>ab ;	

:con.print.byte 
	ab>r 
		a>r 2/ 2/ 2/ 2/ con.print.digit 
		r>a con.print.digit 
	r>ab ;

:con.print.word
	ab>r 
		bswap con.print.byte bswap con.print.byte 
	r>ab ;

// ************************************************************************************************
//										Get a keystroke
// ************************************************************************************************

:con.getkey
	b>r
	begin key@ 0= until
	begin key@ until
	r>b
;

[crunch]