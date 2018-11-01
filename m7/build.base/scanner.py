# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		scanner.py
#		Purpose:	Assembly source code builder.
#		Date:		25th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

import os,sys,re

assert len(sys.argv)==3,"Missing target or level"
levelMax = int(sys.argv[2])
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
	# get level
	m = re.search("level(\d)",f["filename"])
	assert m is not None,"Level missing in "+f
	f["level"] = int(m.group(1))
	# read source
	src = [x.replace("\t"," ") for x in open(f["filename"]).readlines()]
	# find type and word.
	for s in src:
		if s.find("@name") > 0:
			m = re.match("^\;\s*\@name\s*(.*)$",s)
			assert m is not None
			f["word"] = m.group(1).lower().strip()
			f["doc"] = ""
		if s.find("@type") > 0:
			m = re.match("^\;\s*\@type\s*(.*)$",s)
			assert m is not None
			f["type"] = m.group(1).lower().strip()
		if s.find("@desc") > 0:
			m = re.match("^\;\s*\@desc\s*(.*)$",s)
			assert m is not None
			f["doc"] = f["doc"] + " " + m.group(1).lower().strip()
			f["doc"] = f["doc"].strip()
	assert f["word"] != "" and f["type"] in ["macro","word"],"Bad type "+f["type"]+" "+f["word"]
	# remove comments, blank lines from source
	src = [x if x.find(";") < 0 else x[:x.find(";")] for x in src]
	src = [x.rstrip() for x in src if x.rstrip() != ""]
	# work out label name using ASCII codes so we don't have label problems.
	asciiname = "_".join(["{0:02x}".format(ord(x)) for x in f["word"]])
	name = "define_{1}_{0}".format(f["type"],asciiname)
	eName = "defend_{1}_{0}".format(f["type"],asciiname)
	# add the starting label (and ending label if a macro) and an informative comment.
	src.insert(0,name+":")
	src.insert(0,"; ******** {0} ********".format(f["word"]))
	if f["type"] == "macro":
		src.insert(2," db   {0}-{1}-1".format(eName,name))
		src.append(eName+":")
	# store source
	f["source"] = src
#
#		Create the corewords.asm file
#
h = open("asm"+os.sep+"corewords.asm","w")
h.write(";\n;		automatically generated\n;\n")
for f in sourceList:
	if f["level"] <= levelMax:
		h.write("\n".join(f["source"]))
		h.write("\n\n; ---------------------------------------------\n\n")
h.close()
#
#		Create the words.html file.
#
sourceList.sort(key = lambda x:x["word"])
h = open("words.html","w")
h.write("<html><head></head><body>\n")
for f in sourceList:
	h.write("<h3>{0}              ({1})</h1>\n".format(f["word"],f["type"]))
	desc = [x.strip() for x in f["doc"].strip().split(".") if x.strip() != ""]
	desc = ".".join(x[0].upper()+x[1:] for x in desc)
	while desc.find("  ") >= 0:
		desc = desc.replace("  "," ")
	h.write("<p>"+desc+"</p><hr />\n")
h.write("</body></html>\n")
h.close()
