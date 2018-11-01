#
#	Built boot.img (which is the basic one with just the assembler stuff)
#
cd ../kernel
sh build.sh
cd ../system
#
#	Get the boot image and the bootloader here.
#
cp ../files/boot.img . 
cp ../files/bootloader.sna .
#
#	Load in the source code
#
python3 ../files/loadbootstrap.py core.zf test.zf
#
#	And run it.
#
wine ../bin/CSpect.exe -cur -brk -zxnext bootloader.sna 2>/dev/null
