# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makeref.py
#		Purpose : 	make reference file.
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	17th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import re

references = {}
#
#	Read in the listing file, and extract lines with label values on it.
#	(first bit is snasm-only)
#
src = [x.strip().lower() for x in open("kernel.mbin.vice").readlines()]
#
#	For each line, see if it fits the <label> = $<address>
#
for l in src:
	m = re.match("^al\s+c\:([0-9a-f]+)\s+_([0-9a-z_]+)$",l)
	if m is not None:
		#
		#	If so, extract name and address
		#		
		name = m.group(2)
		address = int(m.group(1),16)
		#
		#	If it is definition, get name, checking if it is a macro and
		#	convert back to standard ASCII
		#
		if name[:11] == "definition_":
			name = name[11:]
			isMacro = False
			if name[-6:] == "_macro":
				name = name[:-6]
				isMacro = True
			name = "".join([chr(int(x,16)) for x in name.split("_")])
			name = name.lower()
			if isMacro:
				name = "&&"+name
			references[name.lower()] = address
		#
		#	Extract required labels (coldstart/baseaddress and systeminfo table)
		#
		if name == "coldstart":
			references["$baseaddress"] = address
		if name == "systeminformation":
			references["$systeminfo"] = address

assert "$baseaddress" in references
assert "$systeminfo" in references
#
#	Write the file out.
#
keys = [x for x in references]
keys.sort(key = lambda x:references[x])
ref = "\n".join(["{0}:=${1:06x}".format(x,references[x]) for x in keys])
h = open("kernel.mref","w").write(ref+"\n")