# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makedictionary.py
#		Purpose : 	Build the dictionary and update boot.img
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	30th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,re

print("Initialising MZ Dictionary.")
dictionary = {}
wTypes = { "word":0x00,"const":0x01,"macro":0x02,"macro.nx":0x42,"word.nx":0x40 }
#
#		Read in all the labels
#
labels = [x.lower() for x in open("boot.img.vice").readlines() if x.find("MZ_DEFINE") > 0]
#
#		Convert to name,address,type
#
for l in labels:
	m = re.match("^al\s+c\:([0-9a-f]+)\s+_mz_define_(.*)$",l)
	assert m is not None,l
	address = int(m.group(1),16)
	descriptor = "".join([chr(int(x,16)) for x in m.group(2).split("_")])
	descriptor = descriptor.split("_")
	name = descriptor[0]
	wType = descriptor[1]
	assert name not in dictionary,name+"duplicate"
	dictionary[name] = { "name":name,"address":address,"type":wType }
	print("\t${0:04x} {1} {2}".format(address,name,wType))
#
#		Open image and read it in
#
h = open("boot.img","rb")
bootImage = [x for x in h.read(-1)]
h.close()
#
#		Find the dictionary info page
#
sysInfoTable = bootImage[4]+bootImage[5]*256
print("System Information is at ${0:04x}".format(sysInfoTable))
dictPage = bootImage[sysInfoTable - 0x8000 + 0]
print("Dictionary page is ${0:02x}".format(dictPage))
dAddr = 0x4000 + (dictPage - 0x20) * 0x2000
#
# 		Pad out so space for whole dictionary.
#
while len(bootImage) < dAddr + 0x4000:
	bootImage.append(0)
#
#		Pad out everything else with spaces.
#
fullSize = 0x4000+(0x40 * 0x2000)
while len(bootImage) < fullSize:
	bootImage.append(32)
	
#
#		Get list of words and sort by address
#
words = [x for x in dictionary.keys()]
words.sort(key = lambda x:dictionary[x]["address"])
#
#		Copy words in.
#
for w in words:
	bootImage[dAddr+0] = 6 + len(w)
	bootImage[dAddr+1] = 0xFF
	bootImage[dAddr+2] = dictionary[w]["address"] & 0xFF
	bootImage[dAddr+3] = dictionary[w]["address"] >> 8
	bootImage[dAddr+4] = wTypes[dictionary[w]["type"]]
	words = [ord(x) for x in w.upper()]
	words.append(0)
	for i in range(0,len(w)):
		bootImage[dAddr+i+5] = words[i]

	dAddr = dAddr+6+len(w)
	bootImage[dAddr] = 0

dAddr = (dAddr & 0x3FFF)+0xC000
bootImage[sysInfoTable - 0x8000 + 4] = dAddr & 0xFF
bootImage[sysInfoTable - 0x8000 + 5] = dAddr >> 8
print("Dictionary built to ${0:04x}".format(dAddr))
#
#		Write boot image out
#	
h = open("boot.img","wb")
h.write(bytes(bootImage))
h.close()
