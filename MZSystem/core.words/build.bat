@echo off
del /Q boot.img
del /Q boot_save.img
pushd ..\kernel
call build.bat
popd
copy ..\files\boot.img .
copy ..\files\bootloader.sna .
python ..\files\mzimport.py atomic.mz active.mz test.mz
