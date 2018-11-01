@echo off
set PROJECT=consoletest
set M7COMPILER=..\compiler\cm7.py 
del /Q %PROJECT%.sna
pushd ..\build.base
call build.bat
popd
python %M7COMPILER% %PROJECT%.m7
if exist %PROJECT%.sna copy console.m7 ..\library