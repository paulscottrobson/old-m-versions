@echo off
set PROJECT=sprites
del /Q %PROJECT%.sna
pushd ..\..\build.base
call build.bat
popd
python ..\..\compiler\cm7.py %PROJECT%.m7
