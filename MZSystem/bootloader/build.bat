@echo off
rem
rem		Build the bootloader - standard.
rem
del /Q bootloader.sna
del /Q ..\files\bootloader.sna
..\bin\snasm -next -vice bootloader.asm  bootloader.sna
if exist bootloader.sna copy bootloader.sna ..\files

