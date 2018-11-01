# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makedictionary.py
#		Purpose : 	Create Dictionary that is built in to the Kernel.
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	6th October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import re
#
#		Get words to insert
#
dictionary = {}
words = [x.lower().strip() for x in open("kernel.lst").readlines() if x[:10] == "__mzdefine"]
for w in words:
	m = re.match("^([\w]+)\s+\=\s+\$([0-9a-f]+)",w)
	name = "".join([chr(int(x,16)) for x in m.group(1)[11:].split("_")])
	name = name.lower()
	isMacro = False
	address = int(m.group(2),16)
	if name[-2:] == "/m":
		name = name[:-2]
		isMacro = True
	dictionary[name] = { "name":name,"ismacro":isMacro,"address":address }
#
#		Get names in order
#
words = [x for x in dictionary.keys()]
words.sort(key = lambda x:dictionary[x]["address"])
#
#		Read in the boot image
#
h = open("boot.img","rb")
image = [x for x in h.read(-1)]
h.close()
sysInfo = image[4]+image[5]*256
codePage = image[sysInfo+2-0x8000]
print("Information at ${0:04x}".format(sysInfo))
print("First code page ${0:02x}".format(codePage))
assert image[sysInfo+3-0x8000] == 0x20,"Dictionary not in page $20"
#
#		Insert all entries
#
pos = 0x4000
for w in words:
	#print("\t'{0}' at ${1:04x} entry at ${2:04x}".format(w,dictionary[w]["address"],pos))
	wordo = [ord(x) for x in w]
	image[pos+0] = len(w) + 7 									# offset
	image[pos+1] = sum(wordo) & 0xFF 							# checksum.
	image[pos+2] = codePage 									# page
	image[pos+3] = dictionary[w]["address"] & 0xFF				# address
	image[pos+4] = dictionary[w]["address"] >> 8
	image[pos+5] = 2 if dictionary[w]["ismacro"] else 0 		# type
	wordo.append(0)
	for c in range(0,len(wordo)):
		image[pos+6+c] = wordo[c]
	pos = pos + len(w) + 7
image[pos] = 0
#
#		Update next free
#
nextFree = (pos & 0x3FFF) + 0xC000
print("Dictionary runs ${0:04x} to ${1:04x}".format(0xC000,nextFree))
image[sysInfo+4-0x8000] = nextFree & 0xFF
image[sysInfo+5-0x8000] = nextFree >> 8
#
#		Write it out
#
h = open("boot.img","wb")
h.write(bytes(image))
h.close()
