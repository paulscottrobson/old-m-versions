@echo off
call build.bat
if exist boot.img copy ..\files\bootloader.sna .
if exist boot.img ..\bin\cspect.exe -zxnext -cur -brk bootloader.sna
