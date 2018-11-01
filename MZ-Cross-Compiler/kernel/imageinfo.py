# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		imageinfo.py
#		Purpose : 	Information dump of image file.
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	6th October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

image = [x for x in open("boot.img","rb").read(-1)]
baseAddress = 0x8000
sysInfo = image[4]+image[5]*256
print("SystemInformation at ${0:04x}".format(sysInfo))
print("\tNext free code byte            ${0:04x}".format(image[sysInfo+0-baseAddress]+image[sysInfo+1-baseAddress]*256))
print("\tPage next free code byte       ${0:02x}".format(image[sysInfo+2-baseAddress]))
print("\tDictionary page                ${0:02x}".format(image[sysInfo+3-baseAddress]))
print("\tDictionary next free code byte ${0:04x}".format(image[sysInfo+4-baseAddress]+image[sysInfo+5-baseAddress]*256))
print("\tBoot Program Address           ${0:04x}".format(image[sysInfo+6-baseAddress]+image[sysInfo+7-baseAddress]*256))
print("\tBoot Program Page              ${0:02x}".format(image[sysInfo+8-baseAddress]))
print("\tStack default value            ${0:04x}".format(image[sysInfo+9-baseAddress]+image[sysInfo+10-baseAddress]*256))
print("")
dictAddr = (image[sysInfo+3-baseAddress]-0x20) * 0x2000 + 0x4000
while image[dictAddr] != 0:
	name = ""
	p = dictAddr + 6
	while image[p] != 0:
		name += chr(image[p])
		p += 1
	name = "'"+name+"'"
	addr = image[dictAddr+3] + image[dictAddr+4] * 256
	info = image[dictAddr+5]
	print("${0:04x} {1:16} Page: ${2:02x} Addr: ${3:04x} Type: {4} Info: ${5:02x}".format(dictAddr|0xC000cd ..,name,image[dictAddr+2],addr,info&7,info&0xF8))
	dictAddr = dictAddr + image[dictAddr]