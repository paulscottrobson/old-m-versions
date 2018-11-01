@echo off
pushd ..\bootloader
call build.bat
popd
pushd ..\kernel
call build.bat
popd
del /Q boot.img
del /Q boot.dict
copy ..\compiler\clean\* clean
copy ..\compiler\bootloader.sna .
python ..\compiler\cm.py level1.m level2.m
if exist boot.img ..\bin\CSpect.exe -zxnext -cur -brk bootloader.sna 

