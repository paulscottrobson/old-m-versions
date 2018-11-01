@echo off
call build.bat
if exist test.sna ..\bin\cspect.exe -zxnext -brk -cur -s28 test.sna 
