#
#		Generates test data for compilation.
#
import random

memory = [0x20] * 0x1980 						# memory from $4080-$59FF

text = """

RED	defines
WHITE comment
GREEN compile
YELLOW immediate



""".replace("\t"," ").replace("\n"," ").upper()
ptr = 0
colour = 0x40
for w in text.split(" "):
	if w != "":
		if w == "RED":
			colour = 0x00
		elif w == "WHITE":
			colour = 0x40
		elif w == "GREEN":
			colour = 0x80
		elif w == "YELLOW":
			colour = 0xC0
		else:
			for i in range(0,random.randint(1,3)):
				memory[ptr] = colour + 0x20
				ptr += 1
			for c in w:
				memory[ptr] = (ord(c) & 0x3F) + colour
				ptr += 1

open("testdata.bin","wb").write(bytes(memory))
