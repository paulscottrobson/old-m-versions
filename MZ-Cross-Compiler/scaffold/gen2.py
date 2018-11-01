import random
ops = [ 2,4,8,16,256,-4,-16 ]
for op1 in ops:
	for c in range(1,10):
		n1 = random.randint(1,0xFFFF)
		if op1 > 0:
			result = (n1 * op1) & 0xFFFF
			op = str(op1)+"*"
		else:
			result = n1
			i = -op1
			while i != 1:
				result = (result >> 1) | (result & 0x8000)
				i = i >> 1
			op = str(-op1)+"/"

		print("\t${0:04x} {1} ${2:04x} validate".format(n1 & 0xFFFF,op,result & 0xFFFF))
	print()