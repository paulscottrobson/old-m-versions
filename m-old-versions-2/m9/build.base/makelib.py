# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		makelib.py
#		Purpose:	Build Python library containing runtime
#		Date:		13th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

import re
#
#	Read in system.bin.vice labels
#
labels = {}
src = [x.lower().strip() for x in open("system.lst").readlines() if x.strip() != ""]
src = [x for x in src if x[:7] == "define_" or x[:11] == "end_define_"]
for l in src:
	m = re.match("^([a-z0-9\_]+)\s*=\s*\$([0-9a-f]+)",l)
	assert m is not None,"Can't understand "+l+" in vice file"
	address = int(m.group(2),16)
	name = m.group(1).strip()
	assert name not in labels
	labels[name] = address
#
#	Create a dictionary of runtime words
#
dictionary = {}
for l in [x for x in labels.keys() if x[:7] == "define_"]:
	m = re.match("^define_([a-z]+)_(.*)$",l)
	assert m is not None,"Bad define label "+l
	wType = m.group(1)
	name = "".join([chr(int(x,16)) for x in m.group(2).split("_")]).lower()
	assert name not in dictionary
	dictionary[name] = { "name":name,"type":wType,"address":labels[l] }
#
#	Create Python library
#
dText = ["'{0}::{1}::{2:04x}'".format(dictionary[x]["name"],dictionary[x]["type"],dictionary[x]["address"]) for x in dictionary.keys()]
dText = "[" + (",".join(dText)) + "]"

bText = [str(x) for x in open("system.bin","rb").read(-1)]
bText = "[" + (",".join(bText)) + "]"

h = open("m_runtime.py","w")
h.write("#\n# AUTOMATICALLY GENERATED\n#\n")
h.write("class MRuntime(object):\n")
h.write("\tdef getBinary(self):\n")
h.write("\t\treturn "+bText+"\n")
h.write("\tdef getDictionary(self):\n")
h.write("\t\treturn "+dText+"\n")
h.close()
print("Built runtime library.")