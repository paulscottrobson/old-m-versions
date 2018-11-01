@echo off
rem
rem		Build Bootloader
rem
pushd ..\bootloader
call build.bat
popd
rem
rem		Create boot.img from the assembly files
rem
del /Q boot.img
..\bin\snasm -vice -next kernel.asm boot.bin
if errorlevel 1 del /Q boot.bin
rem
rem 	Pad it out to 512k, add dictionary items
rem
if exist boot.bin python utility\padimage.py
if exist boot.bin python utility\importdict.py
if errorlevel 1 del /Q boot.img
rem
rem		Copy stuff to the bootstrap folder.
rem
if exist boot.img copy boot.img ..\bootstrap
if exist bootloader.sna copy bootloader.sna ..\bootstrap
copy utility\mimport.py ..\bootstrap\utility
copy utility\z80asm.py ..\bootstrap\utility