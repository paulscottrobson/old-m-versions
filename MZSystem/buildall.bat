@echo off
del /Q files\*.*
cd bootloader
call build.bat
cd ..\kernel
call build.bat
cd ..\core.words
call buildimage.bat
cd ..\ide
call build.bat
cd ..