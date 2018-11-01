@echo off
set TESTFILE=test_process.asm
del /Q boot.img
pushd ..\library.modules
call build.bat
popd
..\bin\snasm.exe -next %TESTFILE% boot.img

