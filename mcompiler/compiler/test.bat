@echo off
pushd ..\bootloader
call build.bat
popd
pushd ..\kernel
call build.bat
popd
del /Q boot.img
del /Q boot.dict
python cm.py test.m
if exist boot.img ..\bin\CSpect.exe -zxnext -cur -brk bootloader.sna 

