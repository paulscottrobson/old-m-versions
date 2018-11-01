@echo off
rem *******************************************************************************************
rem
rem									Build the kernel
rem
rem *******************************************************************************************
del /Q kernel.mbin 
del /Q kernel.mref
del /Q kernel.mbin.vice
del /Q temp\__words.asm kernel.mref 
del /Q ..\compiler\kernel.mref
del /Q ..\compiler\kernel.mbin
rem
rem	Make the file temp/__words.asm which has all the assembler kernel words in it
rem
python makewordasm.py
rem
rem	Assemble it to produce .mbin file, kernel.lst used for analysis
rem
..\bin\snasm -vice kernel.asm kernel.mbin
rem
rem	Analyse list files to extract words and macros, then copy to compiler	
rem
if exist kernel.mbin python makeref.py
if exist kernel.mbin copy kernel.mbin ..\compiler >NUL
if exist kernel.mref copy kernel.mref ..\compiler >NUL