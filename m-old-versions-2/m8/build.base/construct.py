# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		construct.py
#		Purpose:	Use the label file to build the dictionary.
#		Date:		11th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

import re
#
#	Extract thr relevant labels from the system.vice file. Assembler dependent
#
labels = {}
if True:		# ** SNASM version **
	for l in [x.upper() for x in open("system.bin.vice").readlines() if x.strip() != ""]:
		m = re.match("^AL\s*C\:([0-9A-F]+)\s*\_(.*)",l)
		assert m is not None,l
		name = m.group(2).strip()
		if name[:7] == "DEFINE_" or name[:11] == "END_DEFINE_":
			labels[name] = int(m.group(1),16)
#
#	Get dictionary information from labels
#
dictionary = {}
for l in [x for x in labels.keys() if x[:7] == "DEFINE_"]:
	m = re.match("^DEFINE_([A-Z]+)_(.*)$",l)
	assert m is not None,l
	# rebuild name
	name = "".join([chr(int(x,16)) for x in m.group(2).split("_")])
	# construct dictionary entry
	dictionary[name] = { "name":name,"type":m.group(1).lower(),"address":labels[l]}
	# if macro calculate size
	if dictionary[name]["type"] == "macro":
		dictionary[name]["size"] = labels["END_"+l]-labels[l]
#
#	Load the binary and find the address of the dictionary.
#
h = open("system.bin","rb")
binary = [x for x in h.read(-1)]
h.close()
offset = 0x5B00
sysinfo = dictionary["system.info"]["address"]
dictionaryPointer = binary[sysinfo-offset+10] + binary[sysinfo-offset+11] * 256
print("Dictionary built from ${0:04x}".format(dictionaryPointer))

keys = [x for x in dictionary.keys()]
keys.sort(key = lambda x:dictionary[x]["address"])
for k in keys:
	name = dictionary[k]["name"].upper()
	dp = dictionaryPointer - offset
	#print("   {0} at ${1:04x}".format(name,dictionaryPointer))

	id = 0 																			# 0 = standard call type word
	if dictionary[k]["type"] == "macro":											# 1..15 = macro expansion of given size
		id = dictionary[k]["size"]	
		assert id > 0 and id < 16
	if dictionary[k]["type"] == "variable":											# 64 = variable
		id = 0x40
	if dictionary[k]["type"] == "immediate":										# 65 = immediate (execute now)
		id = 0x41

	nameOrd = [ord(x) for x in name]												# name as ASCII
	nameOrd[-1] += 0x80 															# set high bit of name last character

	binary[dp+0] = len(name) + 5 													# +0 offset to next, normally len(name) + 5
	binary[dp+1] = dictionary[k]["address"] & 0xFF									# +1 LSB of address
	binary[dp+2] = dictionary[k]["address"] >> 8 									# +2 MSB of address
	binary[dp+3] = 0 																# +3 page of address
	binary[dp+4] = id 																# +4 identifier (see above, bit 7 = private)
	for i in range(0,len(nameOrd)):													# +5 name as u/c ASCII, last has bit 7 set
		binary[dp+5+i] = nameOrd[i]

	binary[dp+5+len(name)] = 0 														# add the terminating zeri
	dictionaryPointer = dictionaryPointer + len(name) + 5 							# advance the pointer

print("Dictionary built to ${0:04x}".format(dictionaryPointer))
binary[sysinfo-offset+0] = dictionaryPointer & 0xFF									# write pointers back
binary[sysinfo-offset+1] = dictionaryPointer >> 8

h = open("system.core","wb")														# write out the core.dir
h.write(bytes(binary))
h.close()