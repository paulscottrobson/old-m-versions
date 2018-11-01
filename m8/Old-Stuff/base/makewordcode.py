# ********************************************************************************************************
# ********************************************************************************************************
#
#		Name : 		makewordcode.py
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Purpose : 	Build composite __words.asm from .asm files in words subdirectory
#		Date : 		7th September 2018
#
# ********************************************************************************************************
# ********************************************************************************************************

import os,re
#
#		Create list of files
#
fileList = []
for root,dirs,files in os.walk("words"):
	for f in files:
		fileList.append(root+os.sep+f)
fileList.sort()
#
#		Build a big source file.
#
h = open("__words.asm","w")
h.write(";\n;  **** AUTOMATICALLY GENERATED ****;\n;\n")
#
#		For each file
#	
for f in fileList:
	print("Importing "+f)
	h.write(";\n; File : {0}\n;\n".format(f))
	#
	#	Read it in
	#
	for l in open(f).readlines():
		#
		#	convert ; @word <name> [macro] to a suitable label
		#
		if l.find("@word") >= 0:
			m = re.match("^\;\s*\@word\s*([\w\,]+)\s*(\w*)$",l.lower())
			assert m is not None,l
			w = "_".join(["{0:02x}".format(ord(x)) for x in m.group(1)])
			w = w if m.group(2) != "macro" else w + "_macro"
			w = "definition_"+w
			h.write(w+":\n")
		#
		#	remove comments, tabs, right strip
		#
		l = l if l.find(";") < 0 else l[:l.find(";")]
		l = l.rstrip().replace("\t", " ")
		#
		#	output only lines with text in.
		#
		if l != "":
			h.write(l+"\n")
h.close()