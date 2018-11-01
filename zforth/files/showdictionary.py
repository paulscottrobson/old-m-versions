# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		showdictionary.py
#		Purpose : 	Display dictionary contents
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	29th October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import sys
file = "boot.img" if len(sys.argv) == 1 else sys.argv[1]
#
#		Load in the binary
#
h = open(file,"rb")
image = [x for x in h.read(-1)]
h.close()
#
#		Work out where things are.
#
sysInfo = image[4] + image[5] * 256
dictPage = image[sysInfo+12-0x8000]
print("System information at  ${0:04x}".format(sysInfo))
print("Dictionary page is     ${0:02x}".format(dictPage))
imageAddress = 0x4000 + (dictPage - 0x20) * 0x2000
print("Dictionary data offset ${0:04x}".format(imageAddress))
defaultPage = image[sysInfo+20-0x8000]
print("Default page is        ${0:02x}".format(defaultPage))
endDictionary = image[sysInfo+4-0x8000] + image[sysInfo+5-0x8000]*256
print("Dictionary ends at     ${0:04x}".format(endDictionary))

p = imageAddress
while image[p] != 0:
	print("\tAt Dictionary : ${0:02x}:${1:04x}".format(dictPage,p|0xC000))
	p1 = p + 6
	name = ""
	while image[p1] != 0:
		name += chr(image[p1]).lower()
		p1 += 1
	desc = "Word " if (image[p+5] & 7) == 0 else "Macro"
	desc = "Addr " if (image[p+5] & 7) == 0	else desc
	print("\t\t{1:4} {0:20}  ${2:02x}:${3:04x}".format(name,desc,image[p+2],image[p+3]+image[p+4]*256))
	p = p + image[p]