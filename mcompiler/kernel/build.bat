@echo off
rem *******************************************************************************************
rem
rem									Build the kernel
rem
rem *******************************************************************************************
del /Q temp\__words.asm 
del /Q boot.img 
del /Q kernel.lst
rem
rem	Make the file temp/__words.asm which has all the assembler kernel words in it
rem
python makewordasm.py
rem
rem	Assemble it to produce .mbin file, kernel.lst used for analysis
rem
..\bin\snasm -next -vice kernel.asm  boot.img
rem
rem	Analyse list files to extract words and macros, then copy to compiler	
rem
if exist boot.img python makeref.py
if exist boot.img copy boot.img ..\compiler\clean
if exist boot.dict copy boot.dict ..\compiler\clean

