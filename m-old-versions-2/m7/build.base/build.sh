
# ****************************************************************************************************************
# 										Rebuild the core system
# ****************************************************************************************************************
#
#			Tidy everything up first
#
rm asm/*.* system.bin system.lst	 ../compiler/msystem.py words.html
#
#			Where the source is.
#
RUNTIMESOURCE=../dictionary
#
#			Get the assembly support files.
# 	
cp $RUNTIMESOURCE/support.assembly/*.asm asm 
#
#			Build the core assembly file from the dictionary
#
python scanner.py $RUNTIMESOURCE
#
# 		Now build it, generating a label file as well.
#
zasm -buw system.asm -l system.lst -o system.bin
#
#			Now construct the dictionary/binary class
#
if [ -e system.bin ]
then
	python construct.py
	cp words.html ../documents
fi
#
#			If we have the class created ok, copy to compiler directory.
#
if [ -e msystem.py ]
then
	cp msystem.py ../compiler
fi

