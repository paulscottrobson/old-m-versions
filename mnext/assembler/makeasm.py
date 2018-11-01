# ********************************************************************************************************
# ********************************************************************************************************
#
#		Name : 		makeasm.py
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Purpose : 	Hash of Z80 Assembler Instructions.
#		Date : 		7th September 2018
#
# ********************************************************************************************************
# ********************************************************************************************************

def process(x):
	x = x.strip().lower()
	x = x.replace("&0000","aaaa")
	x = x.replace("&00","dd")
	x = x.replace("&4546","rr")
	x = x.replace("&","")
	x = x.replace(" ","")
	return x if x != "" and  x[0] != "-" and x[0]  != '*' and x[0] != "[" and x[:4] != "mos_" and x[:3] != "ed_" else None

src = open("z80oplist.txt").readlines()									# read in lose CR
src = [x.replace("\n"," ") for x in src]
src = src[7:263]														# extract relevant bit
assert src[0][:2] == "00"												# check we've the right bit.
assert src[255][:2] == "FF"

opcodes = {}

for s in src:
	base = int(s[:2],16)
	opcodes[base+0x0000] = process(s[3:18])
	opcodes[base+0xCB00] = process(s[33:45])
	opcodes[base+0xED00] = process(s[62:])
	opcodes[base+0xDD00] = process(s[18:33])
opcodeToBinary = {}
kSort = [x for x in opcodes.keys()]
kSort.sort()
for codes in kSort:
	text = opcodes[codes]
	if text is not None:
		if text not in opcodeToBinary:
				opcodeToBinary[text] = codes

keys = [x for x in opcodeToBinary.keys()]
s = ";".join(["{0:04x}:{1}".format(opcodeToBinary[x],x) for x in keys])
h = open("z80asm.py","w")				
h.write("class Z80Opcodes:\n")
h.write("    def get(self):\n")
h.write("        return \"{0}\"\n".format(s))
h.close()