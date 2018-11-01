#
#	Tidy up
#
rm boot.img kernel.lst ../files/boot.img
#
#	Assemble the kernel file.
#
python3 makewordfiles.py
../bin/zasm -buw kernel.asm -o boot.img -l kernel.lst
#
#	Create the core dictionary.
#
if [ -e boot.img ]
then
	python3 makedictionary.py
	cp boot.img ../files/boot.img
	cp showdictionary.py ../files
	cp loadbootstrap.py ../files
fi
