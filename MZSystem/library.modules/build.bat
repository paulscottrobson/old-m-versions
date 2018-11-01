@echo off
rem
rem			Build the library.asm file.
rem
del /Q library.asm
type paging.asm >>library.asm
type parser.asm >>library.asm
type hardware.asm >>library.asm
type dictionary.asm >>library.asm
type constant.asm >>library.asm
type multiply.asm >>library.asm
type divide.asm >>library.asm
type compiler.asm >>library.asm
type memory.asm >>library.asm
type process.asm >>library.asm
type loader.asm >>library.asm
rem
rem			The data area is always last.
rem
type data.asm >>library.asm
rem
rem			Copy to files area
rem
copy library.asm ..\files
echo Built library file 'library.asm'