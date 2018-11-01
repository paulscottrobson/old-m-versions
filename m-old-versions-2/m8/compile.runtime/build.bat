@echo off
rem ****************************************************************************************************************
rem 										Running compiler
rem ****************************************************************************************************************

del /Q system.sna
pushd ..\build.base
call build.bat
popd
if exist system.core ..\bin\snasm system.asm
if exist system.sna ..\bin\cspect.exe -zxnext -brk system.sna
