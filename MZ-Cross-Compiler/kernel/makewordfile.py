# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makewordfile.py
#		Purpose : 	Put together word files to make temp/words.asm
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	6th October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,sys,re

#
#	Find all source files
#
sources = []
for root,dirs,files in os.walk("words"):
	for f in [x for x in files if x[-4:] == ".asm"]:
		sources.append(root+os.sep+f)
sources.sort()
#
#	Open the output file.
#
h = open("temp"+os.sep+"words.asm","w")
#
#	Copy each file in turn, looking for words/macros
#
print("Constructing word file.")
for src in sources:
	print("\t"+src)
	for l in open(src).readlines():
		l = l.rstrip()
		if l != "" and l[0] == ";" and l.find("@") > 0:
			m = re.match("^\;\s+\@(\w+)\s*(.*)$",l)
			if m is not None:
				wtype = m.group(1).lower()
				name = m.group(2).lower()
				if wtype == "macro":
					name = name + "/m"
				scramblename = "__mzdefine_"+"_".join(["{0:02x}".format(ord(c)) for c in name])
				assert wtype == "word" or wtype == "macro" or wtype == "endm"				
				if wtype == "word" or wtype == "macro":
					h.write(scramblename+":\n")			
				h.write(l+"\n")
				if wtype == "macro":
					h.write("    call MacroExpansion\n")
					h.write("    db end{0}-{0}-4\n".format(scramblename))
					lastmacro = scramblename
				if wtype == "endm":
					h.write("end"+lastmacro+":\n")
		else:
			h.write(l+"\n")
h.close()