pushd ../kernel
sh build.sh
popd
cp ../files/boot.img .
cp ../files/bootloader.sna .
python3 mzc.py test1.mz
cp mzc.py ../files

