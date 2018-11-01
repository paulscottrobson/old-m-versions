
# ****************************************************************************************************************
# 										Rebuild the core system
# ****************************************************************************************************************
#
#			Tidy everything up first
#
rm asm/*.* system.bin system.lst m_runtime.py
#
#			Get the assembly support files.
# 	
cp ../dictionary/support.assembly/*.asm asm
#
#			Build the slow.asm and fast.asm files from the dictionary
#
python scanner.py
#
# 		Now build it, generating a label file as well.
#
zasm -buw system.asm -l system.lst -o system.bin
#
#			Now create the runtime as a Python library
#
python makelib.py
cp m_runtime.py ../compiler
echo 'Copied runtime library to compiler directory'