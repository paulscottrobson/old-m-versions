
[$C000] [$8004] [!]

[words]

:word 43 ;

[$2A] [$8006] [c!] [$C000] [$8004] [!]

:onepass 
	50000 
	for 
		word
	next
	42 con.emit
;

:test 
	$BB92 $AA17
	con.clear
	$5555 con.print.hex con.cr
	64 for onepass next
	con.cr $FFFF con.print.hex con.cr

	debug halt ;

:another ;

[crunch]

[test]

// 64 x 50000 Calls
//
//	Same page : 20s
//	Different page : 1'03s


