n1 = 38109 
n2 = 4618

print("{0:04x}  +  {1:04x} = {2:04x}".format(n1,n2,(n1+n2) & 0xFFFF))
print("{0:04x}  -  {1:04x} = {2:04x}".format(n1,n2,(n1-n2) & 0xFFFF))
print("{0:04x}  *  {1:04x} = {2:04x}".format(n1,n2,(n1*n2) & 0xFFFF))
print("{0:04x}  /  {1:04x} = {2:04x}".format(n1,n2,int(n1 / n2) & 0xFFFF))
print("{0:04x} mod {1:04x} = {2:04x}".format(n1,n2,(n1 % n2) & 0xFFFF))
print("")
print("{0:04x} and {1:04x} = {2:04x}".format(n1,n2,(n1 & n2) & 0xFFFF))
print("{0:04x} or  {1:04x} = {2:04x}".format(n1,n2,(n1 | n2) & 0xFFFF))
print("{0:04x} xor {1:04x} = {2:04x}".format(n1,n2,(n1 ^ n2) & 0xFFFF))
print("")
print("-{0:04x} {1:04x}".format(n1,(-n1) & 0xFFFF))
print("~{0:04x} {1:04x}".format(n1,n1 ^ 0xFFFF))