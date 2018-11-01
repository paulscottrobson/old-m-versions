@echo off
call build.bat
if exist core.sna ..\bin\CSpect.exe -zxnext -brk -cur core.sna
