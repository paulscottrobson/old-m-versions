@echo off
set FIRST=console_test
del /Q %FIRST%.sna 
rem
rem		Remove the next three when happy with core stability
rem
pushd ..\build.base
call build.bat
popd
if exist ..\compiler\msystem.py python ..\compiler\m6c.py %FIRST%.m6
if exist %FIRST%.sna copy console.m6 ..\library


