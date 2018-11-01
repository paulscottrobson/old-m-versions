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
#		Find Dictionary Page
#
dPage = [x.lower() for x in open("boot.img.vice").readlines() if x.find("_DICTIONARYPAGE") > 0][0]
dPage = int(dPage.split(" ")[1][2:],16)
dAddr = (dPage - 0x20) * 0x2000 + 0x4000

print("\tDictionary page = ${0:02x}".format(dPage))
#
#		Read in all the labels
#
labels = [x.lower() for x in open("boot.img.vice").readlines() if x.find("MZ_DEFINE") > 0]
#
#		Cpmvert to name,address,type
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
# 		Pad out so space for whole dictionary.
#
while len(bootImage) < dAddr + 0x4000:
	bootImage.append(0)
#
#		Get list of words and sort by address
#
words = [x for x in dictionary.keys()]
words.sort(key = lambda x:dictionary[x]["address"])
#
#		Copy words in.
#
for w in words:
	bootImage[dAddr+0] = 5 + len(w)
	bootImage[dAddr+1] = dictionary[w]["address"] & 0xFF
	bootImage[dAddr+2] = dictionary[w]["address"] >> 8
	bootImage[dAddr+3] = 0x24
	bootImage[dAddr+4] = wTypes[dictionary[w]["type"]]
	words = [ord(x) for x in w.upper()]
	words[-1] = words[-1] + 0x80
	for i in range(0,len(w)):
		bootImage[dAddr+i+5] = words[i]

	dAddr = dAddr+5+len(w)
	bootImage[dAddr] = 0

dAddr = (dAddr & 0x3FFF)+0xC000
bootImage[0x000C] = dAddr & 0xFF
bootImage[0x000D] = dAddr >> 8
print("Dictionary built to ${0:04x}".format(dAddr))
#
#		Write boot image out
#	
h = open("boot.img","wb")
h.write(bytes(bootImage))
h.close()
