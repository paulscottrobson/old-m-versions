# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		scanner.py
#		Purpose:	Assembly source code builder.
#		Date:		11th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

import os,sys,re
assert len(sys.argv)==2,"Missing target"
#
#		Get source list.
#
sourceList = []
for path,dirs,files in os.walk(sys.argv[1]):
	for f in files:
		if f[-4:] == ".src":
			sourceList.append({ "filename":path+os.sep+f,"word":"","type":"" })
sourceList.sort(key = lambda x:x["filename"])
#
#		For each source file, process it.
#
for f in sourceList:
	#print("Processing "+f["filename"]+" ....")
	# read source
	src = [x.replace("\t"," ") for x in open(f["filename"]).readlines()]
	# find type and word.
	for s in src:
		if s.find("@name") > 0:
			m = re.match("^\;\s*\@name\s*(.*)$",s)
			assert m is not None
			f["word"] = m.group(1).lower().strip()
		if s.find("@type") > 0:
			m = re.match("^\;\s*\@type\s*(.*)$",s)
			assert m is not None
			f["type"] = m.group(1).lower().strip()
	assert f["word"] != "" and f["type"] in ["macro","word","slow","variable","immediate"]
	# do we put this is contented memory or fast memory.
	f["target"] = "fast" if f["type"] == "word" else "slow"
	# remove comments, blank lines from source
	src = [x if x.find(";") < 0 else x[:x.find(";")] for x in src]
	src = [x.rstrip() for x in src if x.rstrip() != ""]
	# work out label name using ASCII codes so we don't have label problems.
	asciiname = "_".join(["{0:02x}".format(ord(x)) for x in f["word"]])
	name = "define_{0}_{1}".format(f["type"],asciiname)
	# add the starting label (and ending label if a macro) and an informative comment.
	src.insert(0,name+":")
	src.insert(0,"; ******** {0} ********".format(f["word"]))
	if f["type"] == "macro":
		src.append("end_"+name+":")
	# store source
	f["source"] = src
#
#	Now generate slow and fast assembler files
#
for target in ["slow","fast"]:
	h = open("asm"+os.sep+target+".asm","w")
	h.write(";\n;		automatically generated\n;\n")
	for f in sourceList:
		if f["target"] == target:
			h.write("\n".join(f["source"]))
			h.write("\n\n; ---------------------------------------------\n\n")
	h.close()
