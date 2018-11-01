@echo off
del /Q boot.img
pushd ..\kernel
rem call build.bat
popd
copy ..\files\boot_core.img boot.img
python ..\files\mzimport.py console.mz dump.mz vlist.mz editor.mz ide.mz

