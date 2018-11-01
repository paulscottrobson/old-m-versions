# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makewordfile.py
#		Purpose : 	Copy word files to temp, adding @macro and @word processing.
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	21st October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,sys,re

print("Constructing word files.")
#
#	Find all source files
#
sources = []
for root,dirs,files in os.walk("words"):
	for f in [x for x in files if x[-4:] == ".asm"]:
		sources.append([root,f])
#
#	Copy each file in turn, looking for words/macros
#
includes = []
lastName = None
for src in sources:
	sourceFile = src[0]+os.sep+src[1]
	targetFile = "temp"+os.sep+src[1]
	print("\t"+sourceFile+" => "+targetFile)
	includes.append(src[1])
	h = open(targetFile,"w")
	for l in open(sourceFile).readlines():
		l = l.rstrip()
		if l != "" and l[0] == ";" and l.find("@") > 0:
			m = re.match("^\;\s+\@(\w+)\s*(.*)$",l)
			if m is not None:
				wtype = m.group(1).lower()
				name = m.group(2).lower()
				assert wtype=="word" or wtype=="macro" or wtype == "endm","Error "+l
				if wtype == "macro":
					lastName = name
					name = name + "/macro"
				if wtype == "endm":
					name = lastName + "/endmacro"
					lastName = None
				scramblename = "__forthdefine_"+"_".join(["{0:02x}".format(ord(c)) for c in name])
				h.write(scramblename+":\n")			
				h.write(l+"\n")
		else:
			h.write(l+"\n")
	h.close()
#
#		Create include file
#
includes.sort()
h = open("temp"+os.sep+"include.asm","w")
h.write("".join(["\tinclude \"{0}\"\n".format(x) for x in includes]))
h.close()

