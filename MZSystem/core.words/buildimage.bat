@echo off
del /Q boot.img
del /Q boot_save.img
pushd ..\kernel
call build.bat
popd
copy ..\files\boot.img .
copy ..\files\bootloader.sna .
python ..\files\mzimport.py atomic.mz active.mz test.mz
if exist boot.img ..\bin\cspect.exe -zxnext -brk -cur -exit bootloader.sna
if exist boot_save.img copy boot_save.img ..\files\boot_core.img
del /Q boot_save.img
