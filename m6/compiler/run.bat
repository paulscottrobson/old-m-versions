@echo off
call build.bat
if exist test1.sna ..\bin\cspect.exe -zxnext -brk -s7 test1.sna
