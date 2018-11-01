@echo off
cd bootloader
call build.bat
cd ..\kernel
call build.bat
cd ..