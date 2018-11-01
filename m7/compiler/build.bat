@echo off
set PROJECT=test
del /Q %PROJECT%.sna
pushd ..\build.base
call build.bat
popd
python cm7.py %PROJECT%.m7
