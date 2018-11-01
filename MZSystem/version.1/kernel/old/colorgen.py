#
#								Color Code Generator
#
import random
code = """
<red> star <green> 42 ;
<red> demo <green> star star star ;
<red> 1+ <green> 35 i, ;
<yellow> demo
"""
code = [x for x in code.replace("\n"," ").replace("\t"," ").upper().split(" ") if x != ""]
colourMap = { "<RED>":0x00,"<WHITE>":0x40,"<GREEN>":0x80,"<YELLOW>":0xC0 }
colour = colourMap["<WHITE>"]
byteList = []
for s in code:
	if s[0] == "<":
		colour = colourMap[s]
	else:
		for i in range(0,random.randint(1,3)):
			byteList.append(colour|0x20)
		for c in s:
			byteList.append(ord(c) & 0x3F | colour)
		for i in range(0,random.randint(1,3)):
			byteList.append(colour|0x20)
print("; "+" ".join(code).lower())
print("db "+",".join(["${0:02x}".format(x) for x in byteList]))
print("")
