# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		corelist.py
#		Purpose:	Dump the dictionary in system.core
#		Date:		11th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

sysinfo = [x for x in open("system.bin.vice").readlines() if x.find("SISYSTEMINFORMATION") > 0]
sysinfo = int(sysinfo[0][5:9],16)

binary = [x for x in open("system.core","rb").read(-1)]
offset = 0x5B00
dictionaryPointer = binary[sysinfo-offset+10] + binary[sysinfo-offset+11] * 256
print("{0:04x}".format(dictionaryPointer))
dp = dictionaryPointer - offset
while binary[dp] != 0:
	name = "".join([chr(x & 0x7F) for x in binary[dp+5:dp+binary[dp]]]).lower()
	print("${0:04x} {4:16} [Type:{3:02x}] @ ${2:02x}.{1:04x}".format(dp,binary[dp+1]+binary[dp+2]*256,binary[dp+3],binary[dp+4],name))

	dp = dp + binary[dp]
