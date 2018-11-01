pushd ../compiler
sh build.sh
popd
cp ../files/boot.img .
cp ../files/bootloader.sna .
cp ../files/mzc.py  .
python3 mzc.py level1.mz valid1.mz
cp mzc.py ../files
wine ../bin/CSpect.exe -cur -brk -zxnext bootloader.sna

