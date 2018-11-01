
rm bootloader.sna ../files/bootloader.sna
../bin/zasm -buw bootloader.asm -l bootloader.lst -o bootloader.sna
if [ -e bootloader.sna ] 
then
	cp bootloader.sna ../files
fi
