# *********************************************************************************
# *********************************************************************************
#
#		File:		construct.py
#		Purpose:	Build python library
#		Date:		15th August 2018
#		Author:		paul@robsons.org.uk
#
# *********************************************************************************
# *********************************************************************************

import os,sys,re

#
#	Convert system.bin to text
#
binary = ",".join([str(x) for x in open("system.bin","rb").read(-1)])
#
#	Get labels from system.bin.vice
#
labels = [x.strip().lower() for x in open("system.bin.vice").readlines() if x.strip() != ""]
#
#	Rip out the information
#
entries = []
for w in labels:
	if w.find("define_") >= 0:
		m = re.match("^al\s*c:\s*([0-9a-f]+)\s*\_define\_(.*)$",w)
		assert m is not None, w
		#print(m.groups())
		address = int(m.group(1),16)
		wType = m.group(2).strip().split("_")[-1].lower()
		wName = "".join([chr(int(x,16)) for x in m.group(2).strip().split("_")[:-1]])
		#print(wName,wType,address)
		entries.append("'"+wName+"__"+wType+"__"+str(address)+"'")
entries.sort()
entries = ",".join(entries)
#
#	Write out library
#
h = open("msystem.py","w")
h.write("#\n#\t\t\tAUTOMATICALLY GENERATED\n#\n")
h.write("class MSystemLibrary(object):\n")
h.write("\tdef getBinary(self):\n")
h.write("\t\treturn [{0}]".format(binary)+"\n")
h.write("\tdef getDictionary(self):\n")
h.write("\t\treturn [{0}]".format(entries)+"\n")
h.close()
print("\nLibrary built successfully.")
