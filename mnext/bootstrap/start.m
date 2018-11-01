

:save.system.position private
;

:restore.system.position private
;

//
//			Dictionary word not defined if here.d == saved value.
//

:dictionary.not.changed private
	1
;

//:status here con.print.hex con.space here.d con.print.hex con.cr ;

:boot
	con.clear 										// Intro message
//	con.red "COLOUR con.print.string
//	con.yellow  "M8 con.print.string
//	con.green "system con.print.string 
//	con.cr
	save.system.position 							// Save TOD/Code
	0 												// No error

:warmstart

	sp.reset 										// Reset stack
	a>r if con.red con.print.string 	  			// If error print in red
		restore.system.position 					// restore on error.
	then
	r>a 0= if buffer.size a>c $E0 buffer fill then 	// If no error then clear buffer
	con.cr con.green
	dictionary.not.changed if 						// If dictionary hasn't changed
		restore.system.position 					// Copy Top Dictionary/Code back
	then
	x.debug 										// Show state then set up edit
 	con.screen.height con.edit.size - 1- con.edit.size edit.setup
 	edit.edit.line 									// edit the input line
	buffer buffer.size + swap do.source 			// Compile/execute it
	0 warmstart  									// If completes okay warmstart no error.

[boot] 												// Run boot word
	