// ***********************************************************************************************
// ***********************************************************************************************
//
//		Name : 		valid1.m
//		Purpose : 	Validate Level 1 words
//		Author :	Paul Robson (paul@robsons.org.uk)
//		Created : 	29th September 2018
//
// ***********************************************************************************************
// ***********************************************************************************************

: main

// ***********************************************************************************************
//
//											- (subtract)
//
// ***********************************************************************************************

$100 a>c
	$206a $1a96 - $05d4 validate
	$5ac0 $2e86 - $2c3a validate
	$c782 $40a9 - $86d9 validate
	$2124 $239e - $fd86 validate
	$2161 $7780 - $a9e1 validate
	$7481 $e070 - $9411 validate
	$b638 $623f - $53f9 validate
	$13f4 $34d2 - $df22 validate
	$1b79 $7ebb - $9cbe validate

// ***********************************************************************************************
//
//											Short adjusters
//
// ***********************************************************************************************
	
$101 a>c
	$f6cc 1+ $f6cd validate
	$83ae 1+ $83af validate
	$2d61 2+ $2d63 validate
	$6c4e 2+ $6c50 validate
	$8df4 1- $8df3 validate
	$255b 1- $255a validate
	$f6d9 2- $f6d7 validate
	$8942 2- $8940 validate

// ***********************************************************************************************
//
//									  Binary Logical Operators
//
// ***********************************************************************************************

$102 a>c
	$35b2 $96e0 and $14a0 validate
	$f8f1 $39bb and $38b1 validate
	$fe12 $d403 and $d402 validate
	$169a $e4e8 and $0488 validate
	$2d3b $1004 and $0000 validate
	$83ad $9bc4 and $8384 validate
	$6d61 $c340 and $4140 validate
	$99a9 $2ae2 and $08a0 validate
	$7b06 $e2e8 and $6200 validate

$103 a>c
	$ede8 $2e26 or $efee validate
	$b25f $3957 or $bb5f validate
	$1a68 $c037 or $da7f validate
	$05ad $b8ef or $bdef validate
	$ca95 $9303 or $db97 validate
	$0082 $6034 or $60b6 validate
	$9b50 $e470 or $ff70 validate
	$b6b4 $1ca6 or $beb6 validate
	$f2ae $e45c or $f6fe validate

$104 a>c
	$dd2d $eb68 xor $3645 validate
	$f8d1 $f605 xor $0ed4 validate
	$21ed $fadb xor $db36 validate
	$6798 $9cef xor $fb77 validate
	$3170 $dc07 xor $ed77 validate
	$0d79 $dcf4 xor $d18d validate
	$50aa $70cd xor $2067 validate
	$78fc $8f0d xor $f7f1 validate
	$cf05 $5209 xor $9d0c validate

// ***********************************************************************************************
//
//										not (1's complement)
//
// ***********************************************************************************************

$105 a>c
	$a3c6 not $5c39 validate
	$152a not $ead5 validate
	$beb8 not $4147 validate
	$dcb8 not $2347 validate
	$13a5 not $ec5a validate
	$7f1a not $80e5 validate
	$d083 not $2f7c validate
	$8159 not $7ea6 validate
	$e45d not $1ba2 validate


// ***********************************************************************************************
//
//										0- (2's complement)
//
// ***********************************************************************************************

$106 a>c
	$2fdf 0- $d021 validate
	$b7b9 0- $4847 validate
	$cd68 0- $3298 validate
	$a4e0 0- $5b20 validate
	$c88e 0- $3772 validate
	$6de9 0- $9217 validate
	$8774 0- $788c validate
	$c1ae 0- $3e52 validate
	$3db7 0- $c249 validate

// ***********************************************************************************************
//
//										Absolute value
//
// ***********************************************************************************************

$107 a>c
	$dba9 abs $2457 validate
	$2ff7 abs $2ff7 validate
	$ff27 abs $00d9 validate
	$df16 abs $20ea validate
	$db0f abs $24f1 validate
	$0f32 abs $0f32 validate
	$9c4f abs $63b1 validate
	$d7e3 abs $281d validate
	$e6a1 abs $195f validate

$FFFF a>b b>c debug halt
