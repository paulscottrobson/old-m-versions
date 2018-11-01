import os,re,sys

override = False

words = """
-	Macro
*	Word
, swap	Macro
/	Word
+	Macro
+! -!	Word
> = < Word
>= != <=	Word
0-	Word
0<	Word
0=	Word
1+ 1- 2+ 2-	Macro
2* 4* 8* Macro
16* 256*	Macro
2/ 4/	Macro
a>b b>a	Macro
a>r r>a Macro
b>r r>b Macro
ab>r r>ab	Macro
abs	Word
and or xor	Word
bswap	Macro
buffer	Word
c! !	Macro
c@ @	Macro
clrscreen	Word
copy	Word
count!	Macro
cursor!	Word
debug	Word
fill	Word
halt	Word
key@	Word
max min	Word
mod	Word
not	Word
port@ port!	Macro
screen!	Word
sysinfo&	Word
true false	Macro""".split("\n")

override2 = False

words = [x.strip().lower().replace("\t"," ") for x in words if x.strip() != ""]
for w in words:
	s = [x for x in w.split(" ") if x != ""]
	assert s[-1] == "macro" or s[-1] == "word"
	for w in s[:-1]:
		fName = w.replace("-","minus").replace("+","plus").replace("*","times").replace("/","div")
		fName = fName.replace("!","pling").replace("@","at").replace("&","amp").replace(",","comma")
		fName = fName.replace("=","equals").replace(">","greater").replace("<","less")
		assert re.match("^([0-9a-z]+)$",fName) is not None,fName+" fails." 
		fName = "..\\dictionary\\core\\"+fName+".src"

		if (not override or not override2) and os.path.exists(fName):
			print("FAIL !"+fName+" exists")
			sys.exit(-1)

		h = open(fName,"w")
		h.write("; {0}\n".format('*' * 64))
		h.write("; {0}\n".format('*' * 64))
		h.write(";\n")
		h.write(";;      Name  {0}\n".format(w))
		h.write(";;      Type  {0}\n".format(s[-1]))
		h.write(";\n")
		h.write(";;$\n")		
		h.write(";\n")
		h.write("; {0}\n".format('*' * 64))
		h.write("; {0}\n".format('*' * 64))
		h.write("\n")
		h.close()