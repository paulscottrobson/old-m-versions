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

import os,re,sys
#
#		Scan .lst files for labels (zasm version)
#
systemInformation = None
baseAddress = None
words = {}
for l in [x.lower() for x in open("kernel.asm.dat.vice").readlines()]:
	m = re.match("^al\s*c\:([0-9a-f]+)\s*_(.*)$",l)
	if m is not None:
		label = m.group(2).strip()
		address = int(m.group(1),16)
		if label == "systemvariables":
			systemInformation = address
		if label == "baseaddress":
			baseAddress = address
		if label[:11] == "definition_":
			address = address
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
h = open("kernel.sna","rb")
binary = [x for x in h.read(-1)]
h.close()
loadOffset = 0x4000 - 27 								# offset load of .SNA file.

dbAddr = systemInformation + 2 - loadOffset 			# address in sysinfo
dictPtr = binary[dbAddr] + binary[dbAddr+1] * 256 		# address of base
print("Dictionary Base ${0:04x} ({0})".format(dictPtr)) 	
dictOffset = dictPtr - loadOffset 						# offset in binary.
#
#		Work out list of words in address order
#
kwords = [x for x in words.keys()]
kwords.sort(key = lambda x:words[x]["address"])
#
#		Now output the dictionary.
#
for w in kwords:
	print("\t {0:04x} {1} ({2:04x}{3})".format(dictOffset+loadOffset,w,words[w]["address"]," Macro" if words[w]["ismacro"] else ""))
	binary[dictOffset] = len(w) + 5
	binary[dictOffset+1] = words[w]["address"] & 0xFF
	binary[dictOffset+2] = words[w]["address"] >> 8
	binary[dictOffset+3] = 0
	binary[dictOffset+4] = len(w)+0x80 if words[w]["ismacro"] else len(w)
	for c in range(0,len(w)):	
		binary[dictOffset+5+c] = ((ord(w.upper()[c]) & 0x3F) ^ 0x20) + 0x20
	dictOffset += (5 + len(w))
binary[dictOffset] = 0
#
#		Write next free back
#
nxAddr = systemInformation + 4							# actual address
nxOffset = nxAddr - loadOffset							# offset in binary
dictEnd = dictOffset + loadOffset 						# real dictionary end
binary[nxOffset] = dictEnd & 0xFF 						# write it back.
binary[nxOffset+1] = dictEnd >> 8
print("Dictionary Ends at {0:04x} ({0})".format(dictEnd))
#
#		Write binary back out
#
h = open("kernel.sna","wb")
h.write(bytes(binary))
h.close()

	