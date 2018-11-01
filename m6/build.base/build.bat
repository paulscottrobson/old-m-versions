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
del /Q ..\compiler\msystem.py 
del /Q words.html
rem
rem			Where the source is.
rem
set RUNTIMESOURCE=..\dictionary
rem
rem			Get the assembly support files.
rem 	
copy %RUNTIMESOURCE%\support.assembly\*.asm asm 
rem
rem			Build the core assembly file from the dictionary
rem
python scanner.py %RUNTIMESOURCE%
rem
rem 		Now build it, generating a label file as well.
rem
..\bin\snasm -vice system.asm system.bin
rem
rem			Now construct the dictionary\binary class
rem
if exist system.bin	python construct.py
if exist system.bin	copy words.html ..\documents
rem
rem			If we have the class created ok, copy to compiler directory.
rem
if exist msystem.py	copy msystem.py ..\compiler

