# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makewordfile.py
#		Purpose : 	Build a file which is a composite of the words sources
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	2nd October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,re
#
#		Get all files involved.
#
fileList = []
for root,dirs,files in os.walk("words"):
	for f in [x for x in files if x[-4:] == ".asm"]:
		fileList.append(root+os.sep+f)
fileList.sort()
#
#		Process all files.
#
hOut = open("temp"+os.sep+"words.asm","w")
for f in fileList:
	for l in [x.rstrip() for x in open(f).readlines()]:
		hOut.write(l+"\n")
		if l.find("@@") > 0:
			m = re.match("^;\s*@@([\w\.]+)\s+(.*)$",l.lower())
			assert m is not None,l
			label = m.group(2).strip()+"_"+m.group(1)
			label = ["{0:02x}".format(ord(x)) for x in label]
			label = "mz_define_"+"_".join(label)
			hOut.write(label+":\n")
hOut.close()
