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
#	Get labels and SIA addresses from system.lst
#
src = [x.strip().lower() for x in open("system.lst").readlines()] 
sysaddrs = [x for x in src if x[:3] == "sia"]
labels = [x for x in src if x[:7] == "define_"]
#
#	Rip out the information
#
entries = []
for w in labels:
	m = re.match("^define\_(\w*)\s*\=\s*\$([0-9a-f]+)",w)
	assert m is not None, w
	address = int(m.group(2),16)
	wType = m.group(1).strip().split("_")[-1].lower()
	wName = "".join([chr(int(x,16)) for x in m.group(1).strip().split("_")[:-1]])
	#print(wName,wType,address)
	entries.append("'"+wName+"__"+wType+"__"+str(address)+"'")
entries.sort()
entries = ",".join(entries)
#
#	Write out library : binary, dictionary and data constants.
#
h = open("msystem.py","w")
h.write("#\n#\t\t\tAUTOMATICALLY GENERATED\n#\n")
h.write("class MSystemLibrary(object):\n")
h.write("\tdef getBinary(self):\n")
h.write("\t\treturn [{0}]".format(binary)+"\n\n")
h.write("\tdef getDictionary(self):\n")
h.write("\t\treturn [{0}]".format(entries)+"\n\n")

for w in sysaddrs:
	w = w.split("=")
	h.write("MSystemLibrary.{0} = 0x{1}\n".format(w[0][3:].strip().upper(),w[1].strip()[1:]))

h.close()
print("\nLibrary built successfully.")
