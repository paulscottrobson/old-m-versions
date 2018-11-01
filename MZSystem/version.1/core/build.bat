@echo off
pushd ..\kernel
call build.bat
popd
copy ..\files\boot.img .
python ..\files\mzimport.py atomic.mz active.mz test.mz

