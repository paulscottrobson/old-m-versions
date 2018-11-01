sh build.sh
python3 loadbootstrap.py core.zf
cp ../files/bootloader.sna .
wine ../bin/CSpect.exe -zxnext -brk bootloader.sna