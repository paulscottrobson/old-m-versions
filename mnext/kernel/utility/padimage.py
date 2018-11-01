# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		padimage.asm
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		22nd September 2018
#		Purpose :	Pad the kernel to full size, and add empty dictionary pointers
#					to pages 32/3 and 34/5
#
# ***************************************************************************************
# ***************************************************************************************

h = open("boot.bin","rb")							# read in binary
boot = [x for x in h.read(-1)]
h.close()

memory = [0x00] * (32 + 1) * 16384 					# create empty space
for i in range(0,len(boot)): 						# copy binary in
	memory[i] = boot[i]

for i in [0x4000,0x8000]:							# put dictionary next free and list end pointers in.
	memory[i+0] = 0x02
	memory[i+1] = 0xC0
	memory[i+2] = 0x00

memory[0x10E78] = 0xC9

h = open("boot.img","wb")							# write image out.	
h.write(bytes(memory))
h.close()