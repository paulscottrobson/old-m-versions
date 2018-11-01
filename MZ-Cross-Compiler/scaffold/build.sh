pushd ../compiler
sh build.sh
popd
cp ../files/boot.img .
cp ../files/bootloader.sna .
cp ../files/mzc.py  .
python3 mzc.py level1.mz level2.mz valid2.mz

