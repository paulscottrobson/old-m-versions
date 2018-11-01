;
;		Build a .SNA file with the source embedded from $C000.
;
		opt 	zxNext
		org 	$5B00
		incbin  "system.core"

		org 	$C000
		incbin 	"runtime.m8"
		db 		0
		
		savesna "system.sna",$5B00

