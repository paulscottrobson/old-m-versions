import random
for i in range(0,30):
	ok = False
	while not ok:
		n1 = random.randint(0,0xFFFF)
		n2 = random.randint(1,0xFFFF)		
		result = n1 % n2	
		ok = result != n1
	print("{0} {1} mod {2} - .h ".format(n1,n2,result))