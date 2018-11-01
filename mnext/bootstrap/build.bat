@echo off
rem
rem		Build bootstrap and kernel
rem
pushd ..\kernel
call build.bat
popd
rem
rem		Import m8 code in.
rem
if exist boot.img python utility\mimport.py atomic.m console.m dump.m editor.m start.m
rem
rem		And run it.
rem
if exist boot.img copy boot.img ..\release
if exist bootloader.sna copy bootloader.sna ..\release
if exist boot.img ..\bin\cspect.exe -cur -brk -zxnext bootloader.sna
