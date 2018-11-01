sh build.sh
if [ -e boot.img ]
then
	cp ../files/bootloader.sna .
	wine ../bin/CSpect.exe -cur -brk -zxnext bootloader.sna
fi