@echo off
rem ****************************************************************************************************************
rem 										Rebuild the core system
rem ****************************************************************************************************************
rem
rem			Tidy everything up first
rem
del /Q asm\*.*
del /Q system.bin
del /Q system.bin.vice
del /Q system.core
del /Q ..\compile.runtime\system.core
rem
rem			Where the source is.
rem
set RUNTIMESOURCE=..\dictionary
rem
rem			Get the assembly support files.
rem 	
copy %RUNTIMESOURCE%\support.assembly\*.asm asm 1>NUL
rem
rem			Build the slow.asm and fast.asm files from the dictionary
rem
python scanner.py %RUNTIMESOURCE%
rem
rem 		Now build it, generating a label file as well.
rem
..\bin\snasm -zxnext -vice system.asm system.bin
rem
rem			Now construct the dictionary.
rem
if exist system.bin python construct.py
if exist system.core copy system.core ..\compile.runtime 1>NUL