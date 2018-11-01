# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		mzc.py
#		Purpose : 	MZ Cross Compiler
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	6th October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import re,os,sys

# ***********************************************************************************************
#										Error class
# ***********************************************************************************************

class CompilerException(Exception):
	def __init__(self,msg):
		self.message = msg
		Exception.__init__(self)


# ***********************************************************************************************
#									Dictionary Class
# ***********************************************************************************************

class Dictionary(object):
	def __init__(self,image):
		self.image = image
		self.lastElement = None
		self.dictPage = image.getByte(0x20,self.image.sysInfo+3)	# page for dictionary.
		self.loadDictionary()										# read dictionary
	#
	#		Add a dictionary item
	#
	def add(self,name,page,address,wtype):
		entry = { "name":name.lower(),"page":page,"address":address,"type":wtype,"private":False }
		entry["indictionary"] = False 								# means has been copied into dict.
		entry["compileonly"] = False 								# can't be executed via console
		if name.lower() in self.dictionary:
			raise CompilerException("Duplicate word "+name.lower())
		self.dictionary[name.lower()] = entry
		self.lastElement = entry
	#
	#		Make last private etc.
	#
	def makeLastPrivate(self):
		self.lastElement["private"] = True
	def makeLastCompileOnly(self):
		self.lastElement["compileonly"] = True
	def makeLastVariable(self):
		self.makeLastPrivate()
		self.lastElement["type"] = 1
	#
	#		Find entry
	#
	def find(self,word):
		word = word.strip().lower()
		return None if word not in self.dictionary else self.dictionary[word]		
	#
	#		Load in the current directory
	#
	def loadDictionary(self):
		self.dictionary = {}
		d = 0xC000 													# where the dictionary is.
		while self.image.getByte(self.dictPage,d) != 0:				# extract each dictionary element
			entry = { "name":"","indictionary":True,"private":False }
			entry["page"] = self.image.getByte(self.dictPage,d+2)
			entry["address"] = self.image.getWord(self.dictPage,d+3)
			entry["type"] = self.image.getByte(self.dictPage,d+5) & 7
			p = d + 6 												# extract ASCIIZ name
			while self.image.getByte(self.dictPage,p) != 0:
				entry["name"] += chr(self.image.getByte(self.dictPage,p))
				p += 1
			self.dictionary[entry["name"]] = entry 					# add to dictionary
			d = d + self.image.getByte(self.dictPage,d)
		self.dictionaryEndLogical = d 								# remember where it ends.
	#
	#		Update the in memory dictionary with any new non-private words
	#
	def updateImageDictionary(self):
		dwords = [x for x in self.dictionary.keys() if not self.dictionary[x]["private"]]
		dwords = [x for x in dwords if not self.dictionary[x]["indictionary"]]
		dwords.sort(key = lambda x:self.dictionary[x]["page"]*65536+self.dictionary[x]["address"])
		d = self.dictionaryEndLogical
		for w in dwords:
			wordo = [ord(x) for x in w]
			self.image.setByte(self.dictPage,d+0,len(w) + 7) 				# offset
			self.image.setByte(self.dictPage,d+1,sum(wordo) & 0xFF) 		# checksum.
			self.image.setByte(self.dictPage,d+2,self.dictionary[w]["page"])# page
			self.image.setWord(self.dictPage,d+3,self.dictionary[w]["address"])	# address
			t = self.dictionary[w]["type"]									# type / compile.only
			t = t if not self.dictionary[w]["compileonly"] else t + 64
			self.image.setByte(self.dictPage,d+5,t)
			wordo.append(0)
			for c in range(0,len(wordo)):
				self.image.setByte(self.dictPage,d+6+c,wordo[c])
			self.dictionary[w]["indictionary"] = True
			d = d + len(w) + 7	
		self.dictionaryEndLogical = d 										# mark end
		self.image.setByte(0x20,d,0)
		self.image.setWord(self.dictPage,self.image.sysInfo+4,self.dictionaryEndLogical|0xC000)
	#
	#		Remove private words
	#
	def removePrivateWords(self):
		oldDictionary = self.dictionary
		self.dictionary = {}
		for k in [x for x in oldDictionary.keys() if not oldDictionary[x]["private"]]:
			self.dictionary[k] = oldDictionary[k]

# ***********************************************************************************************
#										Image class
# ***********************************************************************************************

class Image(object):
	#
	#		Instantiate image, load it in.
	#
	def __init__(self,name = "boot.img"):
		self.name = name 											# save name
		h = open(self.name,"rb") 									# read in binary
		self.image = [x for x in h.read(-1)]
		h.close()
		self.sysInfo = self.getWord(0x20,0x8004) 					# system information.
		self.codePage = self.getByte(0x20,self.sysInfo+2) 			# where to compile to.
		self.codeAddress = self.getWord(0x20,self.sysInfo+0)
		self.dictionary = Dictionary(self)							# read in the dictionary.
		self.echo = None
	#
	#		Save it back out.
	#
	def save(self):
		oldEcho = self.echo
		self.echo = None
		self.dictionary.updateImageDictionary()
		h = open(self.name,"wb")
		h.write(bytes(self.image))
		h.close()
		self.echo = oldEcho
	#
	#		Get current address
	#
	def getPointer(self):
		return self.codeAddress
	def getPage(self):
		return self.codePage
	#
	#		Rewind pointer
	#
	def rewindPointer(self,offset):
		self.codeAddress = self.codeAddress - offset
	#
	#		Get address of dictionary.
	#
	def getDictionaryPhysical(self):
		return self.getPhysicalAddress(self.dictionaryPage,0xC000)
	#
	#		Convert logical address to physical one
	#
	def getPhysicalAddress(self,page,addr):
		if addr < 0xC000:
			return addr & 0x3FFF
		return (addr & 0x3FFF)+0x4000*((page - 0x20) >> 1)+0x4000
	#
	#		Set start address (for main usually)
	#
	def setStartAddress(self,page,address):
		self.setWord(0x20,self.sysInfo+6,address)
		self.setByte(0x20,self.sysInfo+8,page)
	#
	#		Compile byte/word
	#
	def cByte(self,data):
		self.setByte(self.codePage,self.codeAddress,data)
		self.codeAddress += 1
	def cWord(self,data):
		self.setWord(self.codePage,self.codeAddress,data)
		self.codeAddress += 2
	#
	#		Access byte/word
	#
	def getByte(self,page,address):
		return self.image[self.getPhysicalAddress(page,address)]
	def getWord(self,page,address):
		a = self.getPhysicalAddress(page,address)
		return self.image[a] + (self.image[a+1] << 8)
	def setByte(self,page,address,data):
		a = self.getPhysicalAddress(page,address)
		while len(self.image) < a:
			self.image.append(0x00)
		self.image[a] = data
		if self.echo is not None:
			print("${0:02x}:${1:04x} ${2:02x}".format(page,address,data))
	def setWord(self,page,address,data):
		a = self.getPhysicalAddress(page,address)
		while len(self.image) < a:
			self.image.append(0x00)
		self.image[a] = data & 0xFF 
		self.image[a+1] = data >> 8
		if self.echo is not None:
			print("${0:02x}:${1:04x} ${2:04x}".format(page,address,data))

# ***********************************************************************************************
#								Z80 Code Generator
# ***********************************************************************************************

class Z80CodeGenerator(object):
	def __init__(self,image):
		self.image = image
	#
	#		Compile a constant load
	#
	def compileConstant(self,c):
		self.image.cByte(0xEB)									# ex de,hl
		self.image.cByte(0x21)									# ld hl,xxxx
		self.image.cWord(c) 	
	#
	#		Compile a string constant load
	#
	def compileStringConstant(self,s):
		self.image.cByte(0x18) 									# jr 
		self.image.cByte(len(s)+1)
		addr = self.image.getPointer()							# save address
		for c in s: 											# output characters
			self.image.cByte(ord(c)) 	
		self.image.cByte(0)										# terminating zero
		self.compileConstant(addr)								# load address
	#
	#		Compile a call
	#
	def compileCall(self,page,addr):
		farCall =  addr >= 0xC000 and page != self.getPage()	# farcall if different page
		if addr >= 0xC000 and self.getPointer() < 0xC000: 		# farcall if calling $Cxxx from below
			farCall = True
		assert not farCall,"Far call not implemented"
		self.image.cByte(0xCD)									# Call aaaa
		self.image.cWord(addr)
	#
	#		Compile a macro
	#
	def compileMacro(self,page,addr):
		assert self.image.getByte(page,addr) == 0xCD 			# check for call MacroExpand
		assert self.image.getWord(page,addr+1) == 0x8006
		for i in range(0,self.image.getByte(page,addr+3)): 		# for number of bytes
			self.image.cByte(self.image.getByte(page,addr+4+i))	# output macro code.
	#
	#		Compile a break
	#
	def compileBreak(self):
		self.image.cByte(0xDD)									# specific to CSpect emulator.
		self.image.cByte(0x01)
	#
	#		Compile a variable space
	#
	def compileVariableSpace(self):
		self.image.cWord(0)
	#
	#		Compile load variable
	#
	def compileLoadVariable(self,address):
		self.image.cByte(0xEB)									# ex de,hl
		self.image.cByte(0x2A)									# ld hl,(xxxx)
		self.image.cWord(address) 	
	#
	#		Compile load variable
	#
	def compileSaveVariable(self,address):
		self.image.cByte(0x22)									# ld (xxxx),hl
		self.image.cWord(address) 	
	#
	#		Compile test of A and branch, return address of address in JP
	#
	def compileBranch(self,branchType):
		assert branchType == "=0" or branchType == ">=0" or branchType == "#0",branchType
		if branchType == ">=0":
			self.image.cByte(0xCB)								# bit 7.h
			self.image.cByte(0x7C)
			self.image.cByte(0xCA) 								# jp z,
		else:
			self.image.cByte(0x7C)								# ld a,h
			self.image.cByte(0xB5)
			self.image.cByte(0xCA if branchType=="=0" else 0xC2)# jp z or jp nz
		address = self.image.getPointer()
		self.image.cWord(0)
		return address
	#
	#		Patch branch address
	#
	def setBranchTarget(self,addressOfJump,addressOfTarget):
		self.image.setWord(self.image.getPage(),addressOfJump,addressOfTarget)
	#
	#		For Loop code
	#
	def forLoopCode(self,word):
		if word == "for":
			self.forLoopAddress = self.image.getPointer()
			self.image.cByte(0x2B)								# dec hl
			self.image.cByte(0xE5)								# push hl
		elif word == "next":
			self.image.cByte(0xE1)								# pop hl
			addr = self.compileBranch("#0")						# jp if not done
			self.setBranchTarget(addr,self.forLoopAddress)
		else:
			assert False,word+"????"	

# ***********************************************************************************************
#									Line Compiler
# ***********************************************************************************************

class LineCompiler(object):
	def __init__(self,image):
		self.image = image
		self.dictionary = self.image.dictionary
		self.compileEnabled = True
		self.codeGenerator = Z80CodeGenerator(image)
	#
	#		Compile a line
	#
	def compile(self,line):
		line = line if line.find("//") < 0 else line[:line.find("//")]
		line = line.lower().replace("\t"," ").strip()
		self.words = [x for x in line.split(" ") if x != ""]
		self.nextWord = 0
		word = self.get()
		while word != "":
			self.compileWord(word)
			word = self.get()
	#
	#		Get next word or space.
	#
	def get(self):
		if self.nextWord >= len(self.words):
			return ""
		self.nextWord += 1
		return self.words[self.nextWord-1]
	#
	#		Compile a single word.
	#
	def compileWord(self,word):
		if self.image.echo is not None:
			print("; ***** {0} *****".format(word))
		#
		# 		defines and conditional defines
		#
		if word == ":" or word == "::":
			name = self.get()
			if name == "":
				raise CompilerException("Cannot define word without a name")
			# disable compilation if :: and name already exists
			if word == "::" and self.dictionary.find(name) is not None:
				self.compileEnabled = False
				return
			self.dictionary.add(name,self.image.getPage(),self.image.getPointer(),0)
			if name == "main":
				self.image.setStartAddress(self.image.getPage(),self.image.getPointer())
			return

		if not self.compileEnabled:
			return
		#
		# 		constant numbers
		#
		if re.match("^[0-9]+$",word) is not None:
			self.codeGenerator.compileConstant(int(word,10) & 0xFFFF)
			return
		if re.match("^\$[0-9a-f]+$",word) is not None:
			self.codeGenerator.compileConstant(int(word[1:],16) & 0xFFFF)
			return

		#
		#		String constant
		#
		if word[0] == '"' and len(word) > 1:
			self.codeGenerator.compileStringConstant(word[1:].replace("_"," ").upper())
			return
		#
		# 		words (all three types)
		#
		we = self.dictionary.find(word)
		if we is not None:
			if we["type"] == 0:
				self.codeGenerator.compileCall(we["page"],we["address"])
			elif we["type"] == 1:
				self.codeGenerator.compileConstant(we["address"])
			elif we["type"] == 2:
				self.codeGenerator.compileMacro(we["page"],we["address"])
			return
		#
		# 		variable !! and @@
		#
		if word == "variable":
			self.dictionary.makeLastPrivate()
			self.dictionary.makeLastVariable()
			self.codeGenerator.compileVariableSpace()
			return
		if word == "!!" or word == "@@":
			if self.image.getByte(self.image.getPage(),self.image.getPointer()-4) != 0xEB:
				raise CompilerException("Can only apply "+word+" to a variable")
			if self.image.getByte(self.image.getPage(),self.image.getPointer()-3) != 0x21:
				raise CompilerException("Can only apply "+word+" to a variable")
			address = self.image.getWord(self.image.getPage(),self.image.getPointer()-2)
			self.image.rewindPointer(4)
			if word == "@@":
				self.codeGenerator.compileLoadVariable(address)
			else:
				self.codeGenerator.compileSaveVariable(address)
			return
		#
		# 		if/-if then
		#
		if word == "if" or word == "-if":
			self.ifPatchAddress = self.codeGenerator.compileBranch("=0" if word == "if" else ">=0")
			return
		if word == "then":
			self.codeGenerator.setBranchTarget(self.ifPatchAddress,self.image.getPointer())
			return
		# 
		#		begin until/-until
		#
		if word == "begin":
			self.beginTarget = self.image.getPointer()
			return
		if word == "until" or word == "-until":
			addr = self.codeGenerator.compileBranch("=0" if word == "until" else ">=0")
			self.codeGenerator.setBranchTarget(addr,self.beginTarget)
			return
		#
		# 		for next i
		#
		if word == "for" or word == "next" or word == "i":
			self.codeGenerator.forLoopCode(word)
			return
		#
		# 		private break compile.only
		#
		if word == "break":
			self.codeGenerator.compileBreak()
			return
		if word == "private":
			self.dictionary.makeLastPrivate()
			return
		if word == "compile.only":
			self.dictionary.makeLastCompileOnly()
			return
		#
		#		Give up
		#
		raise CompilerException("Do not understand '{0}'".format(word))

# ***********************************************************************************************
#										File compiler
# ***********************************************************************************************

class FileCompiler(object):
	#
	def __init__(self,image):
		self.image = image
		self.lineCompiler = LineCompiler(image)
		FileCompiler.SOURCEFILE = "<none>"
		FileCompiler.LINENUMBER = 0
	#
	#		Compile file
	#
	def compile(self,source):
		print("\tCompiling {0} ...".format(source))
		if not os.path.isfile(source):
			print("\t\tFile does not exist.")
			sys.exit(1)
		src = open(source).readlines()
		FileCompiler.SOURCEFILE = source
		for l in range(0,len(src)):
			FileCompiler.LINENUMBER = l + 1
			try:
				self.lineCompiler.compile(src[l])			
			except CompilerException as e:
				print("\t\t\t{0} at {1}:{2}".format(e.message,FileCompiler.SOURCEFILE,FileCompiler.LINENUMBER))
				print("\t\t\tCompile failed.")
				sys.exit(-1)

if __name__ == "__main__":
	img = Image()
	fcom = FileCompiler(img)
	print("MZ Compiler v1.0 (07-Oct-18)")
	for s in sys.argv[1:]:
		fcom.compile(s)
	img.save()
	sys.exit(0)
