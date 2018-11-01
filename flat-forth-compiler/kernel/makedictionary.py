# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		makedictionary.py
#		Purpose : 	Construct kernel word dictionary
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	22nd October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

#
#		Decode .lst format
#
def decode(x):
	print(x)
	x = [x for x in x.split(" ") if x != ""]
	name = "".join([chr(int(c,16)) for c in x[0][14:].strip().split("_")]).upper()
	wtype = 'W'
	if name[-6:] == "/macro":
		wtype = 'M'
		name = name[:-6]
	if name[-9:] == "/endmacro":
		wtype = 'E'
		name = name[:-9]
	return [wtype+":"+name,int(x[4],10)]

import os,sys,re

print("Constructing dictionary.")
eos = 0x5E
#
#		Get the words
#
words = [decode(x) for x in open("kernel.lst").readlines() if x[:13] == "__forthdefine"]
wordDict = {}
for w in words:
	assert w[0] not in wordDict,w+" duplicated"
	wordDict[w[0]] = w[1]
#
#		Load in the binary
#
h = open("boot.img","rb")
image = [x for x in h.read(-1)]
h.close()
#
#		Work out where things are.
#
sysInfo = image[4] + image[5] * 256
dictPage = image[sysInfo+4-0x8000]
print("\tSystem information at  ${0:04x}".format(sysInfo))
print("\tDictionary page is     ${0:02x}".format(dictPage))
imageAddress = 0x4000 + (dictPage - 0x20) * 0x20000
print("\tDictionary data offset ${0:04x}".format(imageAddress))
defaultPage = image[sysInfo+12-0x8000]
print("\tDefault page is        ${0:02x}".format(defaultPage))

#
#		Pad it out
#
while len(image) < imageAddress + 0x4000:
	image.append(0)

#
#		Write the dictionary.
#
p = imageAddress
image[p] = 0 														# end of dictionary.
print("\tDictionary ends at     ${0:02x}".format(p|0xC000))
#
#		Update dict next free
#
p = p | 0xC000
image[sysInfo+0-0x8000] = p & 0xFF
image[sysInfo+1-0x8000] = p >> 8
#
#		Write back
#
h = open("boot.img","wb")
h.write(bytes(image))
h.close()

print(wordDict)
