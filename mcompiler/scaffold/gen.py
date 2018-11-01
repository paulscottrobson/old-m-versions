import random
for c in range(1,10):
	n1 = random.randint(1,0xFFFF)
	n2 = random.randint(2,0xFFFF)
	result = ((-n1) & 0xFFFF) if (n1 & 0x8000) else n1
	op = "abs"
	#print("\t${0:04x} ${1:04x} {2} ${3:04x} validate".format(n1,n2,op,result))
	print("\t${0:04x} {1} ${2:04x} validate".format(n1,op,result))
