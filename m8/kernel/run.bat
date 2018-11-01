@echo off
rem
rem		Build the kernel
rem
call build.bat
rem
rem		Bodge version of code insertion for testing
rem
if exist kernel.sna	python loadscript.py
rem
rem		Run it
rem
..\bin\cspect.exe -zxnext -brk -cur kernel.sna 
