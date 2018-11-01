@echo off
rem
rem		Build the bootloader (no testing)
rem
del /Q bootloader.sna
..\bin\snasm -next -vice bootloader.asm  bootloader.sna
if exist bootloader.sna copy bootloader.sna ..\compiler

