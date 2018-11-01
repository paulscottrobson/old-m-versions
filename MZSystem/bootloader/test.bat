@echo off
rem
rem		Test the boot read/write works
rem 
del /Q bootloader.sna 
del /Q boot_save.img
rem
rem		Create a dummy boot.img file large enough
rem
python makerandomimage.py
rem
rem		Assemble with testing on
rem
..\bin\snasm -next -vice -d TESTRW bootloader.asm  bootloader.sna
rem
rem		Run it
rem
if exist bootloader.sna  ..\bin\cspect.exe -zxnext -cur -brk bootloader.sna
rem
rem		Check it was copied in and out successfully.
rem
if exist boot_save.img fc /b boot.img boot_save.img
del /Q bootloader.sna