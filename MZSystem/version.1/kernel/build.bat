@echo off
rem *******************************************************************************************
rem
rem									Build the kernel
rem
rem *******************************************************************************************
del /Q boot.img
del /Q bootloader.sna
del /Q temp\words.asm
rem
rem		Create temp\words.asm scanned for words and macros etc.
rem
python makewordfile.py
rem
rem		Assemble it to produce .mbin file, kernel.lst used for analysis
rem
..\bin\snasm -next -vice kernel.asm boot.img
rem
rem 	Import the dictionary bound words into the dictionary
rem
if exist boot.img python makedictionary.py
copy boot.img 	 ..\files
copy mzimport.py ..\files
copy z80asm.py   ..\files
