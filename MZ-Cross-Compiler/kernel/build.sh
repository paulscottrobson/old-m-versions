#
#	Tidy up
#
rm boot.img kernel.lst ../files/boot.img
python3 makewordfile.py
#
#	Assemble the kernel file.
#
../bin/zasm -buw kernel.asm -o boot.img -l kernel.lst
#
#	Create the core dictionary.
#
if [ -e boot.img ]
then
	python3 makedictionary.py
	cp boot.img ../files	
	cp imageinfo.py ../files
fi