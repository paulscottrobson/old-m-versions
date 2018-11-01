@echo off
del /Q boot.img
pushd ..\library.modules
call build.bat
popd
python makewordfile.py
..\bin\snasm.exe -next -vice kernel.asm boot.img
if exist boot.img python makedictionary.py
if exist boot.img copy boot.img ..\files
copy mzimport.py ..\files
copy z80asm.py ..\files

python mzimport.py test.mz
rem python mzimport.py test_paging.mz

