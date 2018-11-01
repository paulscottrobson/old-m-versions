@echo off
rem
rem			Delete files
rem
del /Q kernel.sna  
del /Q system/kernel.sna 
del /Q __words.asm
del /Q kernel.asm.dat
del /Q kernel.asm.dat.vice
rem
rem			Create __words.asm by scanning files
rem
python makewordcode.py
rem
rem			Assembler kernel
rem
..\bin\snasm -zxnext -vice -d LOBOOT kernel.asm
rem
rem			Load in internal dictionary words
rem
if exist kernel.sna	python makedictionary.py
rem
rem			Copy to system directory
rem
if exist kernel.sna copy kernel.sna ..\system
