@echo off
rem
rem		Build the bootloader (no testing)
rem
del /Q bootloader.sna
..\bin\snasm -vice -next bootloader.asm
if errorlevel 1 del /Q bootloader.sna
if exist bootloader.sna copy bootloader.sna ..\kernel
