# ********************************************************************************************************
# ********************************************************************************************************
#
#		Name : 		makedictionary.py
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Purpose : 	Build internal dictionary
#		Date : 		7th September 2018
#
# ********************************************************************************************************
# ********************************************************************************************************

import os,re
#
#		Scan .lst files for labels (zasm version)
#
systemInformation = None
baseAddress = None
words = {}
for l in [x.lower() for x in open("core.lst").readlines()]:
	if l.find("=") >= 0:
		m = re.match("^(.*)\s*=\s*\$([0-9a-f]+)",l)
		if m is not None:
			label = m.group(1).strip()
			if label == "systemvariables":
				systemInformation = int(m.group(2),16)
			if label == "baseaddress":
				baseAddress = int(m.group(2),16)
			if label[:11] == "definition_":
				address = int(m.group(2),16)
				isMacro = False
				if label[-6:] == "_macro":
					label = label[:-6]
					isMacro = True
				name = "".join([chr(int(x,16)) for x in label[11:].split("_")])				
				entry = { "name":name,"address":address,"ismacro":isMacro }
				assert name not in words,"Duplicate "+name
				words[name] = entry
assert systemInformation is not None,"SystemInformation: not found"
assert baseAddress is not None,"BaseAddress: not found"
print("Base address ${0:04x}".format(baseAddress))
print("System Information ${0:04x}".format(systemInformation))
#
#		Load in the binary and find out where dictionary base is.
#
h = open("core.bin","rb")
binary = [x for x in h.read(-1)]

dbAddr = systemInformation + 2 - baseAddress 			# address in sysinfo
dictPtr = binary[dbAddr] + binary[dbAddr+1] * 256 		# address of base
print("Dictionary Base ${0:04x} ({0})".format(dictPtr)) 	
dictOffset = dictPtr - baseAddress 						# offset in binary.
#
#		Work out list of words in address order
#
kwords = [x for x in words.keys()]
kwords.sort(key = lambda x:words[x]["address"])
#
#		Now output the dictionary.
#
for w in kwords:
	print("\t {0:04x} {1} ({2:04x})".format(dictOffset+baseAddress,w,words[w]["address"]))
	binary[dictOffset] = len(w) + 5
	binary[dictOffset+1] = words[w]["address"] & 0xFF
	binary[dictOffset+2] = words[w]["address"] >> 8
	binary[dictOffset+3] = 0
	binary[dictOffset+4] = len(w)+0x80 if words[w]["ismacro"] else len(w)
	for c in range(0,len(w)):	
		binary[dictOffset+5+c] = ord(w.upper()[c]) & 0x3F
	dictOffset += (5 + len(w))
binary[dictOffset] = 0
#
#		Write next free back
#
nxAddr = systemInformation + 4
nxOffset = nxAddr - baseAddress
dictEnd = dictOffset + baseAddress
binary[nxOffset] = dictEnd & 0xFF
binary[nxOffset+1] = dictEnd >> 8
print("Dictionary Ends at {0:04x} ({0})".format(dictEnd))
#
#		Write binary back out
#
h = open("core.bin","wb")
h.write(bytes(binary))
h.close()
