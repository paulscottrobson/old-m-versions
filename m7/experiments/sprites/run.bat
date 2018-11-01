@echo off
call build.bat
if exist %PROJECT%.sna	..\..\bin\cspect.exe -zxnext -brk %PROJECT%.sna