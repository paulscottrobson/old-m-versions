
rm core.sna core.lst core.bin __words.asm
python makewordcode.py
zasm -buw core.asm -l core.lst -o core.bin
if [ -e core.bin ]
then
	python makedictionary.py
	python makesna.py
fi