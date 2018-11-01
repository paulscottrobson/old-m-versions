@echo off
del /Q test.sna 
del /Q kernel.sna 
del /Q *.html
pushd "..\kernel"
call build.bat
popd
python m8import.py atomic.m8 words.m8 console.m8 dump.m8 editor.m8 	test.m8
