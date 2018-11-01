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
	x = [x for x in x.split(" ") if x != ""]
	name = "".join([chr(int(c,16)) for c in x[0][11:].strip().split("_")]).lower()
	wtype = 'F'
	if name[-6:] == "/macro":
		wtype = 'M'
		name = name[:-6]
	return [name,int(x[4],10),wtype]

import os,sys,re

print("Constructing dictionary.")
eos = 0x5E
#
#		Get the words
#
#
#		Get the words
#
words = [decode(x) for x in open("kernel.lst").readlines() if x[:10] == "__cfdefine"]
words.sort(key = lambda x:x[0])
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
dictPage = image[sysInfo+12-0x8000]
print("\tSystem information at  ${0:04x}".format(sysInfo))
print("\tDictionary page is     ${0:02x}".format(dictPage))
imageAddress = 0x4000 + (dictPage - 0x20) * 0x20000
print("\tDictionary data offset ${0:04x}".format(imageAddress))
defaultPage = image[sysInfo+20-0x8000]
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
for w in words:

	whash = 137														# calculate the hash.
	for c in [ord(x) for x in w[0].upper()]:						# this has to do the same calculation as 
		whash = (whash + (c & 0x3F)) & 0xFF 						# DICTCalculateHash in dictionary.asm
		whash = (whash >> 1) + ((whash & 0x01) << 7)

	#print("\t\tRecord at ${0:02x}:${1:04x} Address ${2:02x}:${3:04x} {4} {5}".format(dictPage,p | 0xC000,defaultPage,w[1],w[2],w[0]))
	image[p] = len(w[0])+7											# length
	image[p+1] = whash 												# initial hash (unused)
	image[p+2] = defaultPage 										# Page number
	image[p+3] = w[1] & 0xFF 										# Address
	image[p+4] = w[1] >> 8
	image[p+5] = 0x40 if w[2] == 'M' else 0x00						# type information.
	for c in range(0,len(w[0])):									# name
		image[p+6+c] = ord(w[0].upper()[c]) & 0x3F
	image[p+6+len(w[0])] = eos										# ASCIIZ marker.
	p = p + len(w[0]) + 7

image[p] = 0 														# end of dictionary.
print("\tDictionary ends at     ${0:02x}".format(p|0xC000))
#
#		Update dict next free
#
p = p | 0xC000
image[sysInfo+4-0x8000] = p & 0xFF
image[sysInfo+5-0x8000] = p >> 8
#
#		Write back
#
h = open("boot.img","wb")
h.write(bytes(image))
h.close()
