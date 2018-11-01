import random
for c in range(1,10):
	n1 = random.randint(1,0xFFFF)
	n2 = random.randint(2,0x0FFF)
	if random.randint(0,1) == 1:
		n2 = random.randint(2,0x00FF)
	result = int(n1 % n2)

	op = "mod"
	print("\t${0:04x} ${1:04x} {2} ${3:04x} validate".format(n1 & 0xFFFF,n2 & 0xFFFF,op,result & 0xFFFF))
	#print("\t${0:04x} {1} ${2:04x} validate".format(n1 & 0xFFFF,op,result & 0xFFFF))
