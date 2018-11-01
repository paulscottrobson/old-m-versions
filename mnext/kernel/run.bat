@echo off
call build.bat
rem
rem		Import m8 code in.
rem
if exist boot.img python utility\mimport.py test.m8
rem
rem		And run it.
rem
if exist boot.img ..\bin\cspect.exe -cur -brk -zxnext bootloader.sna
