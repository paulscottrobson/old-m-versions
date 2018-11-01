@echo off
del /Q core.asm.dat
del /Q core.asm.dat.vice
del /Q core.sna
python testdata.py
..\bin\snasm -vice core.asm
