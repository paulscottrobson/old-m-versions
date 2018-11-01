@echo off
call build.bat
copy ..\files\bootloader.sna .
if exist boot.img ..\bin\cspect.exe -zxnext -brk -cur bootloader.sna

