
[words]

:test 
	$BB92 $AA17
	con.clear
	con.red 42 con.emit con.space
	con.yellow 42 con.emit 3 con.spaces
	con.green 42 con.emit
	con.white 42 con.emit con.cr

	$1A4F con.print.hex con.cr con.print.bin con.cr
	32767 con.print.dec con.cr 

	$23EA con.print.byte con.cr con.print.word con.cr
	con.getkey con.clear con.print.dec
	con.yellow
	0 dump.mem
	con.green
	begin con.getkey con.print.byte con.space 0 until 

	debug halt ;

:another ;

[crunch]

[test]

