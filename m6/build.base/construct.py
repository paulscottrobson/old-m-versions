# *********************************************************************************
# *********************************************************************************
#
#		File:		construct.py
#		Purpose:	Build python library
#		Date:		25th August 2018
#		Author:		paul@robsons.org.uk
#
# *********************************************************************************
# *********************************************************************************

import os,sys,re
#
#	Format conversion (SNASM Vice)
#
def convertVice(l):
	l = l.lower().strip()
	if l == "":
		return None
	m = re.match("^al\sc:(\w+)\s*_(.*)$",l)
	assert m is not None,"Format of "+l
	return [m.group(2).strip(),int(m.group(1),16)]
#
#	Convert system.bin to text
#
binary = ",".join([str(x) for x in open("system.bin","rb").read(-1)])
#
#	Get labels from system.bin.vice
#
labels = {}
src = [x.strip().lower() for x in open("system.bin.vice").readlines()] 
for s in src:
	cv = convertVice(s)
	if cv is not None:
		labels[cv[0]] = cv[1]
#
#	Rip out the information
#
entries = []
for w in labels.keys():
	if w[:7] == "define_":
		address = labels[w]
		wType = w[7:].split("_")[-1].lower()
		wName = "".join([chr(int(x,16)) for x in w[7:].split("_")[:-1]])
		#print(wName,wType,address)
		entries.append("'"+wName+"__"+wType+"__"+str(address)+"'")
entries.sort()
entries = ",".join(entries)
#
#	Read 'compile only' list
#
coList = open("compileonly.lst").read(-1)
coList = "[" + ",".join(['"'+x+'"' for x in coList.split("__")]) + "]"
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
h.write("\tdef getCompileOnlyList(self):\n")
h.write("\t\treturn {0}".format(coList)+"\n\n")

for w in labels.keys():
	if w[:3] == "sia":
		h.write("MSystemLibrary.{0} = 0x{1:04x}\n".format(w.upper()[3:],labels[w]))


h.close()
print("\nLibrary built successfully.")
