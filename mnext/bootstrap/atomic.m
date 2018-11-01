// ********************************************************************************************************
// ********************************************************************************************************
//
//		Name : 		atomic.m
//		Author : 	Paul Robson (paul@robsons.org.uk)
//		Purpose : 	Low level atomic functions
//		Date : 		24th September 2018
//
// ********************************************************************************************************
// ********************************************************************************************************

// ********************************************************************************************************
//
//												MACROS Section
//
// ********************************************************************************************************

[macros]
//
// 		return from caller, compiles return and then return compiled manually
//
:; 		{ret} a, [{ret}] [a,] 	

//
//		CSPECT breakpoint
//
:brk 	$DD01 a, ;

//
//		Integer addition
//
:+ 		{add.hl,de} a, ;

//
//		Integer subtraction
//
:- 		{xor.a} a, {ld.b,h} a, {ld.c,l} a, {ex.de,hl} a, {sbc.hl,bc} a, ;

//
//		Swap A & B
//
:swap 	{ex.de,hl} a, ;

//
//		Incrementers/Decrementers
//
:2+ 	{inc.hl} a,
:1+ 	{inc.hl} a, ;
:2- 	{dec.hl} a,
:1- 	{dec.hl} a, ;
//
//		Scalars
//
:16* 	{add.hl,hl} a,
:8* 	{add.hl,hl} a,
:4* 	{add.hl,hl} a,
:2* 	{add.hl,hl} a, ;
:4/ 	{sra.h} a, {rr.l} a,
:2/ 	{sra.h} a, {rr.l} a, ;
//
:256* 	{ld.h,l} a, {ld.l,dd} a, 0 c, ;

//
//		Register->Register
//
:a>b 	{ld.d,h} a, {ld.e,l} a, ;
:a>c 	{push.hl} a, {pop.ix} a, ;
:b>a 	{ld.h,d} a, {ld.l,e} a, ;
:b>c 	{ld.ixh,d} a, {ld.ixl,e} a, ;
:c>a 	{push.ix} a, {pop.hl} a, ;
:c>b 	{ld.d,ixh} a, {ld.e,ixl} a, ;

//
//		Register to/from stack
//
:a>r 	{push.hl} a, ;
:b>r 	{push.de} a, ;
:c>r 	{push.ix} a, ;
:r>a 	{pop.hl} a, ;
:r>b 	{pop.de} a, ;
:r>c 	{pop.ix} a, ;
:ab>r 	{push.hl} a, {push.de} a, ;
:abc>r 	{push.hl} a, {push.de} a, {push.ix} a, ;
:r>ab 	{pop.de} a, {pop.hl} a, ;
:r>abc 	{pop.ix} a, {pop.de} a, {pop.hl} a, ;

//
//		Memory read/write indirect
//
:@		{ld.a,(hl)} a, {inc.hl} a, {ld.h,(hl)} a, {ld.l,a} a, ;
:c@		{ld.l,(hl)} a, {ld.h,dd} a, 0 c, ;
:! 		{ld.(hl),e} a, {inc.hl} a, {ld.(hl),d} a, {dec.hl} a,
:c! 	{ld.(hl),e} a, ;

//
//		Input/Output to/from port
//
:port@ 	{ld.b,h} a, {ld.c,l} a, {in.l,(c)} a, {ld.h,dd} a, 0 c,  ;
:port! 	{ld.b,h} a, {ld.c,l} a, {out.(c),e} a, ;

//
//		Byte swap
//
:bswap	{ld.a,h} a, {ld.h,l} a, {ld.l,a} a, ;

// ********************************************************************************************************
//
//												WORDS Section
//
// ********************************************************************************************************

[words]

//
//		Executable versions of words - no stack manipulators or return (;) as they cannot be executed
//		(nor can the breakpoint for CSpect, obviously :) )
//
:+ 		+ ;
:- 		- ;
:swap 	swap ;
:bswap 	bswap ;
:1+ 	1+ ;	:1- 	1- ;	:2+ 	2+ ;	:2- 	2- ;
:2* 	2* ;	:4* 	4* ;	:8* 	8* ;	:16* 	16* ;	:256* 	256* ;
:2/ 	2/ ;	:4/ 	4/ ;	
:a>b 	a>b ;	:a>c 	a>c ;	:b>a 	b>a ;	:b>c 	b>c ;	:c>a 	c>a ;	:c>b 	c>b ;
:@ 		@ ; 	:c@ 	c@ ;	:! 		! ; 	:c! 	c! ;
:port@	port@ ;	:port!	port! ;

// 
//		Divide by 16
//
:16/ 	4/ 4/ ;
//
//		Absolute value : Note : falls through to negate
//
:abs 	<bit.7,h> <ret.z>
//
//		Negate (2's complement) A
//
:0- 	<ld.a,h> <cpl> <ld.h,a> <ld.a,l> <cpl> <ld.l,a> <inc.hl> ;

//
//		Not (1's complement) A
//
:not 	<ld.a,h> <cpl> <ld.h,a> <ld.a,l> <cpl> <ld.l,a>  ;

//
//		Check equal zero.
//
:0= 	<ld.a,h> <or.l> <ld.hl,aaaa> [0] [,] <ret.nz> <dec.hl> ;

//
//		Check less zero.
//
:0< 	<bit.7,h> <ld.hl,aaaa> [0] [,] <ret.z> <dec.hl> ;

//
//		Halt the CPU
//
:halt 	<di> <halt> <jrrr> [$FC] [,] ;

//
//		Equality testers
//
:= 		<xor.a> <sbc.hl,de> <dec.hl> <ret.z> <ld.hl,aaaa> [0] [,] ;
:<>		<xor.a> <sbc.hl,de> <ret.z> <ld.hl,aaaa> [-1] [,] ;

//
//		Comparision testers
//
:>= 	<dec.hl>
:> 		<xor.a> <sbc.hl,de> <sbc.a,a> <ld.l,a> <ld.h,a> ;

:<= 	<inc.hl>
:< 		<xor.a> <ex.de,hl> <sbc.hl,de> <sbc.a,a> <add.hl,de> <ex.de,hl> <ld.l,a> <ld.h,a> ;

//
//		Binary operators
//
:and 	<ld.a,l> <and.e> <ld.l,a> <ld.a,h> <and.d> <ld.h,a> ;
:or  	<ld.a,l> <or.e> <ld.l,a> <ld.a,h> <or.d> <ld.h,a> ;
:xor  	<ld.a,l> <xor.e> <ld.l,a> <ld.a,h> <xor.d> <ld.h,a> ;

//
//		Minimum / Maximum values
//
:min 	<xor.a> <sbc.hl,de> <ld.a,h> <add.hl,de> <or.a> <ret.m> <ld.l,e> <ld.h,d> ;
:max 	<xor.a> <sbc.hl,de> <ld.a,h> <add.hl,de> <or.a> <ret.p> <ld.l,e> <ld.h,d> ;

//
//		Get Free Code address variable address & current value
//
:h 		$8004 ;
:here 	h @ ;

// ********************************************************************************************************
//
//										This code is macro structures
//
// ********************************************************************************************************

//
//		Loop locations for internal structures
//
variable if.marker  						// Branch position for if marker.
variable begin.marker  						// Branch back for begin
variable for.marker 						// Branch back for for

[macros]
//
//		Set Private macro.
//
:private $80 orflagbits ;
	
//
//		If ... Then code 
//
:if 	{ld.a,h} a, {or.l} a, {jp.z,aaaa} a,
		here if.marker! 0 ,
		;
:-if 	{bit.7,h} a, {jp.z,aaaa} a,
		here if.marker! 0 ,
		;
:then	here if.marker@ !
		;

//
//		Begin ... Until code
//
:begin 	here begin.marker! 
		;
:until 	{ld.a,h} a, {or.l} a, {jp.z,aaaa} a, begin.marker@ ,
		;
:-until	{bit.7,h} a, {jp.z,aaaa} a, begin.marker@ ,
		;

//
//		For ... Next code
//
:for 	here for.marker!
		{dec.hl} a, {push.hl} a,
		;
:next 	{pop.hl} a, {ld.a,h} a, {or.l} a, {jp.nz,aaaa} a, for.marker@ ,
		;
:i 		{pop.hl} a, {push.hl} a, ;

[words]
