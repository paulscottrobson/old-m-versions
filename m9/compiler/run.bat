@echo off
pushd ..\kernel
call build.bat
popd
del /Q test.sna
python linecompiler.py
if exist test.sna ..\bin\CSpect.exe -zxnext -brk -cur test.sna
