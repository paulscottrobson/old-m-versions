# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makewordasm.py
#		Purpose : 	make word definitions into a single file for assembly.
#				    add labels that allow analysis of the file for words/macros
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	17th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,sys,re

fileList = []												# build list of source files
for root,dirs,files in os.walk("levels"):					# by walking levels subdirectory			
	for f in files:											# add all assembly files to the list
		if f[-4:] == ".asm":
			fileList.append(root+os.sep+f)
fileList.sort()												# sort it for consistency

h = open("temp"+os.sep+"__words.asm","w")					# build "all words" file.
for f in fileList:
	currentOpen = None
	for l in open(f).readlines():							# read all lines, do basic processing
		l = l.rstrip().replace("\t"," ")
		if l.find("@") >= 0:								# worth checking
			m = re.match("^\;\s*\@(\w+)\s*(.*)$",l)			# start/end of macro or wprd ?
			if m is not None:
															# handle start of word or macro
				if m.group(1) == "word" or m.group(1) == "macro":
					h.write("\n; **** {0} {1} ****\n".format(m.group(2),m.group(1)))
					currentOpen = "definition_"+("_".join(["{0:02x}".format(ord(x)) for x  in m.group(2)]))
					if m.group(1) == "macro":
						currentOpen = currentOpen + "_macro"
					h.write(currentOpen+":\n")
					if m.group(1) == "macro":
						h.write(" db end_{0}-{0}-1\n".format(currentOpen))
															# end of macro, output a label to
				if m.group(1) == "endmacro":				# use to calculate macro size.
					h.write("end_{0}:\n".format(currentOpen))
			l = None
		if l is not None and l != "" and l[0] != ';':		# output no blank lines that aren't
			h.write(l+"\n")									# comment only.
h.close()
