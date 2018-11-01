#
#								Simple core builder
#								===================
#
#	Creates a 64k memory image, clears the text area, loads in the main
#	binary. The text is then converted into 2+6 format, and the result saved
# 	as an .SNA file
#
import random

memory = [0x00] * 0x10000 					# CPU Memory
for i in range(0x4000,0x5A00):				# Set the text transfer space to $20
	memory[i] = 0x20
binCode = [x for x in open("kernel.bin","rb").read(-1)]
for i in range(0,len(binCode)):				# Copy the binary stuff in
	memory[0x5B00+i] = binCode[i]

memory[0x4000-27] = 0x3F 					# add .SNA data
memory[0x4000-4] = 0xFE
memory[0x4000-3] = 0x5A
memory[0x4000-2] = 1
memory[0x4000-1] = 7

memory[0x5AFE] = 0x00
memory[0x5AFF] = 0x5B

text = """

YELLOW MACROS

RED ; GREEN $C9 C, YELLOW $C9 C, 

GREEN ; ; ;  YELLOW $1BCD $2AFE DEBUG

""".replace("\t"," ").replace("\n"," ").upper()
ptr = 0x4000
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

h = open("kernel.sna","wb").write(bytes(memory[0x4000-27:]))
