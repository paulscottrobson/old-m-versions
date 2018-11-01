#
#								Simple core builder
#								===================
#
import random

h = open("kernel.sna","rb")
snaBinary = [x for x in h.read(-1)]
h.close()
loadOffset = 0x4000 - 27

for x in range(0x4100,0x5A00):
	snaBinary[x-loadOffset] = 0x20

text = """

yellow macros

red ; green $c9 c, yellow $c9 c, 

green ; ; ;  

yellow m8words

red test green  clrscreen 0 cursor! 42 1 screen! $1bcd $2afe debug halt ;

yellow test

""".replace("\t"," ").replace("\n"," ").upper()

ptr = 0x4100 - loadOffset

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
				snaBinary[ptr] = colour + 0x20
				ptr += 1
			for c in w:
				snaBinary[ptr] = (ord(c) & 0x3F) + colour
				ptr += 1

h = open("kernel.sna","wb")
h.write(bytes(snaBinary))
h.close()

print("Loaded embedded script into kernel.snaw")