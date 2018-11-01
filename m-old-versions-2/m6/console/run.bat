@echo off
call build.bat
if exist %FIRST%.sna ..\bin\cspect.exe -zxnext -brk -s7 %FIRST%.sna
