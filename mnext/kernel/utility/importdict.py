# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		importdict.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		24th September 2018
#		Purpose :	Add internal dictionary items to the boot image.
#
# ***************************************************************************************
# ***************************************************************************************

import re,sys
#
#		Calculate hash. Mirrors __DICTCalculateHash otherwise it won't work :)
#
def wordHash(word):
	value = 0xA7
	for w in word.upper():
		value = (value >> 1) | ((value & 1) << 7)			# RRC 
		value = value + (ord(w) & 0x3F) 					# ADD
		value = value & 0xFF
	return value

#
#		Read in the boot image file
#
h = open("boot.img","rb")							
image = [x for x in h.read(-1)]
h.close()

#
# 		Read in the labels file
#
labels = {}							
for l in [x.strip().lower() for x in open("boot.bin.vice").readlines()]:
	if l != "":
		m = re.match("^al\s+c\:([0-9a-f]+)\s_(.*)$",l)
		assert m is not None,l
		labels[m.group(2).strip()] = int(m.group(1),16)

#
#		Read in the import-words file.
#		
words = [x.strip().lower().replace("\t"," ") for x in open("inbuilt.txt").readlines()]
words = [x if x.find("//") < 0 else x[:x.find("//")] for x in words]
words = [x.strip() for x in words if x.strip() != ""]

#
#		Add words to physical dictionary
#
currentPage = None 													# address of dictionary currently being updated.
for w in words:
	if w[0] == "<" and w[-1] == ">":								# switch dictionary ?
		currentPage = (int(w[1:-1])-32)*0x2000+0x4000
		print("Switching to dictionary @ ${0:04x}".format(currentPage))
	else:															# new word
		name = w[:w.find(" ")] 										# get name, label
		label = w[w.find(" "):].strip()
		if label not in labels:										# check we know the label.
			print(name+" is an unknown label")
			sys.exit(1)
		address = labels[label] 									# get address

		nextFree = image[currentPage] + image[currentPage+1] * 256	# next free logical address
		pAddress = nextFree - (0xC000) + currentPage 				# where it actually is in the image

		nextFree = nextFree + 7 + len(name) 						# make space for it.
		image[currentPage] = nextFree & 0xFF 						# and write it back
		image[currentPage+1] = nextFree >> 8

		print("\tAdding '{0}' code ${1:06x} real:${2:06x} image:${3:06x}".format(name,address,nextFree,pAddress))

		image[pAddress+0] = len(name)+7 							# offset next
		image[pAddress+1] = wordHash(name)							# hash of name
		image[pAddress+2] = address & 0xFF 							# address
		image[pAddress+3] = address >> 8 
		image[pAddress+4] = 0x24 									# page number, put it in the first page.
		image[pAddress+5] = 0x00 									# zero flags
		image[pAddress+6] = len(name)								# name length.
		for i in range(0,len(name)): 								# name text
			image[pAddress+7+i] = ord(name.upper()[i])
		image[pAddress+len(name)+7] = 0 							# end marker 

h = open("boot.img","wb")							# write image out.	
h.write(bytes(image))
h.close()

