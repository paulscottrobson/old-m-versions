@echo off
rem ****************************************************************************************************************
rem									Compile dictionary and sna file
rem ****************************************************************************************************************
rem
rem	Note: the rebuild of the dictionary is only necessary when it's under development.
rem
rem		Clean up
rem
del /Q test1.sna 
del /Q msystem.py
rem
rem		Switch to the dictionary build directory and build it.
rem
pushd ..\build.base
call build.bat
popd
rem
rem		If dictionary built okay, compile the source
rem
if exist msystem.py	python m6c.py test1.m6


