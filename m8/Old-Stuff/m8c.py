# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		m8c.py
#		Purpose:	Simple M6 Compiler.
#		Date:		1st September 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

import os,sys,re
from msystem import *

# ****************************************************************************************
#								 Exception Class
# ****************************************************************************************

class CompilerException(Exception):
	def __init__(self,msg):
		self.message = msg

# ****************************************************************************************
#								 Binary Object Class
# ****************************************************************************************

class Binary(object):
	def __init__(self):
		self.binary = [0x00] * 0x10000 										# empty memory space
		mlib = MSystemLibrary()												# get library object
		core = mlib.getBinary()
		for i in range(0,len(core)):										# copy binary in
			self.binary[MSystemLibrary.LOADADDRESS + i] = core[i]
		self.lastWritten = MSystemLibrary.LOADADDRESS + len(core)			# last byte written
		self.codePtr = self.readWord(MSystemLibrary.PROGRAMPOINTER)			# where we start writing code
		self.dataPtr = self.readWord(MSystemLibrary.DATASPACE)				# data space (works backwards)
		self.echo = False
	#
	#			Accessors and Mutators
	#
	def read(self,addr):													# access/mutate
		return self.binary[addr]
	def readWord(self,addr):
		return self.binary[addr]+self.binary[addr+1] * 256
	def write(self,addr,data):
		self.lastWritten = max(self.lastWritten,addr)
		data = data & 0xFF
		self.binary[addr] = data
		if self.echo:
			print("\t{0:04x} : {1:02x}   {2:c}".format(addr,data,((data & 0x3F) ^ 0x20) + 0x20))
	def writeWord(self,addr,data):
		self.lastWritten = max(self.lastWritten,addr+1)
		data = data & 0xFFFF
		self.binary[addr] = data & 0xFF
		self.binary[addr+1] = data >> 8
		if self.echo:
			print("\t{0:04x} : {1:04x}".format(addr,data))
	def cByte(self,data):													# compile a byte
		self.write(self.codePtr,data)
		self.codePtr += 1
	def cWord(self,data):													# compile a word
		self.writeWord(self.codePtr,data)
		self.codePtr += 2
	#
	#			Set the start address
	#
	def setMain(self,mainAddress):
		self.writeWord(MSystemLibrary.RUNTIMEADDRESS,mainAddress)
	#
	#			Claim data from the data space
	#
	def getDataMemory(self,size):
		self.dataPtr = self.dataPtr - size 									# allocated backwards.
		for i in range(0,size):												# clear allocated memory
			self.write(self.dataPtr + i,0)
		return self.dataPtr
	#
	#			Generate a snap or some other loading file.
	#
	def generateSnapFile(self,stub):
		self.writeWord(MSystemLibrary.PROGRAMPOINTER,self.codePtr)			# update code pointer
		self.writeWord(MSystemLibrary.DATASPACE,self.dataPtr)				# update data pointer.
		self.echo = False
		self.codePtr = 0x4000-27											# 27 byte SNA header
		self.cByte(0x3F)
		for i in range(0,9):
			self.cWord(0)
		for i in range(0,4):
			self.cByte(0)
		self.cWord(0x5AFE)													# SP
		self.cByte(1)
		self.cByte(7)
		assert self.codePtr == 0x4000
		self.writeWord(0x5AFE,0x5B00)										# put start $5B00 at
		h = open(stub+".sna","wb")											# write as a snap file.
		h.write(bytes(self.binary[0x4000-27:0x10000]))
		h.close()
	#
	#			Create dictionary 
	#
	def createDictionary(self,dictionary):
		self.echo = False
		words = dictionary.getWords()										# get
		dictPtr = self.readWord(MSystemLibrary.DICTIONARYBASE)				# where we start
		for w in words:
			wInfo = dictionary.find(w)
			self.write(dictPtr+0,len(w)+5)									# offset

			self.writeWord(dictPtr+1,wInfo["address"] & 0xFFFF)				# address
			self.write(dictPtr+3,wInfo["address"] >> 16)					# page number

			infoByte = 0													# information byte
			if wInfo["type"] == "variable":
				infoByte += 0x10
			if wInfo["immediate"]:											# (can't be private)
				infoByte += 0x40
			if wInfo["compileonly"]:
				infoByte += 0x80
			self.write(dictPtr+4,infoByte)

			nameCodes = [ord(x) & 0x3F for x in w.upper()]					# 6 bit ASCII name
			nameCodes[-1] += 0x80 											# set bit 7 of last
			for i in range(0,len(nameCodes)):								# write out name.
				self.write(dictPtr+5+i,nameCodes[i])

			dictPtr += (len(w) + 5)											# Next slot.

		self.write(dictPtr,0)												# end of dictionary marker
		self.writeWord(MSystemLibrary.DICTIONARYNEXTFREE,dictPtr)			# write dictionary pointer out.

# ****************************************************************************************
#								   Dictionary Class
# ****************************************************************************************

class Dictionary(object):
	def __init__(self):
		core = MSystemLibrary().getDictionary()								# get dictionary list
		self.words = {}														# create the initial library.
		for c in core:
			c = c.split("__")												# divide into bits
			self.add(c[0],c[1],int(c[2]))
			if c[3].find("compileonly") >= 0:								# check for compile only.
				self.makeLastCompileOnly()
	#
	#			Add in a new entry
	#
	def add(self,name,type,address):
		name = name.lower().strip()											# tidy up
		type = type.lower().strip()
		if name in self.words:												# check duplicates
			raise CompilerException("Duplicate name "+name)
		self.words[name] = { "name":name,"type":type,"address":address }
		self.words[name]["immediate"] = type == "macro"						# macros are immediates
		self.words[name]["private"] = type == "variable"					# variables are always private
		self.words[name]["compileonly"] = False
		self.last = self.words[name]										# remember last definition
	#
	#			Apply "Private" and "Immediate" to last word
	#
	def makeLastPrivate(self):												# make last defined private
		self.last["private"] = True
	def makeLastImmediate(self):											# make last defined immediate
		self.last["immediate"] = True
	def makeLastCompileOnly(self):											# make last defined compile only.
		self.last["compileonly"] = True
	#
	#			Find a dictionary word
	#
	def find(self,name):													# find by name
		name = name.lower().strip()
		return self.words[name] if name in self.words else None				# search for given key
	#
	#			Purge dictionary of all private words
	#
	def removeAllPrivate(self):
		words = self.words 													# keep list
		self.words = {}														# clear it
		for w in words.keys():												# and only copy non private
			if not words[w]["private"]:										# words in.
				self.words[w] = words[w]
	#
	#			Get all words in address order
	#
	def getWords(self):
		words = [x for x in self.words.keys()]
		words.sort(key = lambda x:self.words[x]["address"])
		return words

# ****************************************************************************************
#								   Line Compiler
# ****************************************************************************************

class LineCompiler(object):
	def __init__(self,binaryObject,dictionary):
		self.binary = binaryObject											# working objects
		self.dictionary = dictionary
		self.dictionary.removeAllPrivate()
	#
	#			Compile one line.
	#
	def compile(self,line):
		line = line if line.find("//") < 0 else line[:line.find("//")]		# remove all comments
		line = line.replace("\t"," ").strip()								# remove tabs amd strip spaces
		self.words = [x.strip() for x in line.split(" ") if x.strip() != ""]# get all the words
		self.wordIndex = 0
		self.inComment = False 												# Comments end at EOL
		w = self.getNextWord() 												# process all words
		while w != "":
			self.compileWord(w.lower())
			w = self.getNextWord()
	#
	#			Get next word on this line
	#
	def getNextWord(self):
		if self.wordIndex >= len(self.words):
			return ""
		w = self.words[self.wordIndex]
		self.wordIndex += 1
		return w
	#
	#			Compile a single word
	#
	def compileWord(self,word):
		#
		if self.binary.echo:											# helper stuff
			print("{0}".format(word))
		#
		#		Integer constant
		#
		intNum = self.wordToNumber(word)								# decimal or hex integer
		if intNum is not None:											# if found, compile constant
			self.compileConstant(intNum)
			return		
		#
		#		String constant
		#
		if word[0] == '"':												# string constant			
			self.binary.cByte(0x18)										# JR <over string>
			self.binary.cByte(len(word))
			strAddress = self.binary.codePtr
			self.binary.cByte(len(word)-1)								# length of string
			for c in word[1:].replace("_"," ").upper():					# write out ASCII 6 bit replacing
				self.binary.cByte(ord(c) & 0x3F) 						# with space.
			self.compileConstant(strAddress)
			return
		#
		#		Colon Definition
		#
		if word == ':' :												# colon definition
			newWord = self.getNextWord()								# word being defined
			if newWord == "":
				raise CompilerException(": without word name")
			if self.binary.echo:										# information
				print(" **** "+newWord+" ****")
			self.dictionary.add(newWord,"word",self.binary.codePtr)		# add to dictionary
			if newWord == "main":										# if main set target.
				self.binary.setMain(self.binary.codePtr)
			return
		#
		#		Words (Macro/Immediate AND direct)
		#
		wRec = self.dictionary.find(word)								# words ?
		if wRec is not None:											# in dictionary
			if wRec["type"] == "word":									# immediate words impossible
				if wRec["immediate"]:
					raise CompilerException(word+" is immediate, call cannot be compiled.")
				self.binary.cByte(0xCD)									# call <addr>
				self.binary.cWord(wRec["address"])
			if wRec["type"] == "macro":
				addr = wRec["address"]+3								# skip over the call MacroExpand
				size = self.binary.read(addr)							# to size, followed by data
				assert size >= 0 and size <= 7,"Macro size ? "+word
				for i in range(0,size):
					self.binary.cByte(self.binary.read(addr+i+1))
			return
		#
		#		Modified words (! @ & # added)
		#
		wRec = self.dictionary.find(word[:-1])							# modified words
		if "!@&#".find(word[-1]) >= 0 and wRec is not None:
			if word[-1] == "!":											# store
				self.binary.cByte(0x22)									# ld (address),hl
				self.binary.cWord(wRec["address"])			
			if word[-1] == "@":											# load
				self.binary.cByte(0xEB)									# ex de,hl
				self.binary.cByte(0x2A)									# ld hl,(address)
				self.binary.cWord(wRec["address"])			
			if word[-1] == "&":											# address
				self.compileConstant(wRec["address"])
			if word[-1] == '#':											# array (address + A)
				self.binary.cByte(0x01)									# ld bc,<constant>
				self.binary.cWord(wRec["address"])
				self.binary.cByte(0x09)									# add hl,bc
			return
		#
		#		Control structures
		#
		if word == "begin" or word == "until" or word == "-until":		# structures
			self.compileBeginLoop(word)
			return
		if word == "if" or word == "-if" or word == "then":
			self.compileIfTest(word)
			return
		if word == "for" or word == "next" or word == "i":
			self.compileForLoop(word)
			return
		#
		#		Miscellany
		#
		if word == "private":											# make last definition private
			self.dictionary.makeLastPrivate()
			return

		if word == "immediate":											# make last definition immediate
			self.dictionary.makeLastImmediate()
			return

		if word == "list" :												# control code listing
			ctrl = self.getNextWord()
			if ctrl != "on" and ctrl != "off":
				raise CompilerException("list must be followed by off or on")
			self.binary.echo = (ctrl == "on")
			return

		if word == "variable":											# 2 byte variable
			name = self.getNextWord()									# name of variable
			if name == "":
				raise CompilerException("Missing variable name")
			memory = self.binary.getDataMemory(2)
			self.dictionary.add(name,"word",memory)
			self.dictionary.makeLastPrivate()
			return

		if word == "array":												# array of byte size
			name = self.getNextWord()									# name of variable
			if name == "":
				raise CompilerException("Missing array name")
			size = self.wordToNumber(self.getNextWord())				# get size of array
			if size is None:
				raise CompilerException("Array without valid size")
			memory = self.binary.getDataMemory(size)
			self.dictionary.add(name,"word",memory)
			self.dictionary.makeLastPrivate()
			return
		#
		#		Finally give up
		#
		raise CompilerException("Don't understand '"+word+"'")
	#
	#		Convert word to integer if possible.
	#
	def wordToNumber(self,word):
		if re.match("^\-?[0-9]+$",word):								# decimal constant
			return int(word,10) & 0xFFFF
		if re.match("^\$[0-9a-f]+$",word):								# hex constant
			return int(word[1:],16) & 0xFFFF
		return None

	#
	#			Compile code to swap A/B and load a constant
	#
	def compileConstant(self,constant):
		self.binary.cByte(0xEB)											# ex de,hl
		self.binary.cByte(0x21)											# ld hl,<const>
		self.binary.cWord(constant & 0xFFFF)
	#
	#				Begin and Until/-Until code
	#
	def compileBeginLoop(self,word):
		if word == "begin":
			self.beginAddress = self.binary.codePtr
		else:
			self.binary.cWord(0xB57C if word[0] != "-" else 0x7CCB)		# test for -ve / non-zero
			self.binary.cByte(0x28)
			self.binary.cByte((self.beginAddress - (self.binary.codePtr + 1)) & 0xFF)
	#
	#				If/-If and Then code
	#
	def compileIfTest(self,word):
		if word == "if" or word == "-if":
			self.binary.cWord(0xB57C if word[0] != "-" else 0x7CCB)		# test for -ve / non-zero
			self.binary.cByte(0x28)
			self.ifAddress = self.binary.codePtr
			self.binary.cByte(0x00)
		else:
			self.binary.write(self.ifAddress,self.binary.codePtr - (self.ifAddress+1))
	#
	#				For/Next code
	#
	def compileForLoop(self,word):
		if word == "for":
			self.forAddress = self.binary.codePtr
			self.binary.cByte(0x2B)										# dec HL
			self.binary.cByte(0xE5)										# push HL
		elif word == "next":
			self.binary.cByte(0xE1)										# pop HL
			self.binary.cWord(0xB57C)									# test if zero
			self.binary.cByte(0x20)										# if nz
			self.binary.cByte(self.forAddress-(self.binary.codePtr+1))
		elif word == "i":
			self.binary.cByte(0xEB)										# ex de,hl
			self.binary.cByte(0xE1)										# pop HL
			self.binary.cByte(0xE5)										# push HL
		else:
			assert False

# ****************************************************************************************
#									Project Compiler
# ****************************************************************************************

class ProjectCompiler(object):
	#
	def __init__(self,sourceFile):
		self.binary = Binary()											# create helper objects
		self.dictionary = Dictionary()
		self.lineCompiler = LineCompiler(self.binary,self.dictionary)
		self.imports = {}												# list of imports
		try:
			self.compileFile(sourceFile)								# compile source catching errors
		except CompilerException as err:
			print("*** M8 Error *** {0}:{1} .... {2}".format(ProjectCompiler.FILENAME,ProjectCompiler.LINENUMBER,err.message))
			sys.exit(1)

		self.dictionary.removeAllPrivate()								# remove all private words		
		self.binary.createDictionary(self.dictionary)
		self.binary.generateSnapFile(sourceFile[:-3])					# generate SNA file.
	#
	#			Compile a single file
	#
	def compileFile(self,sourceFile):
		if sourceFile[-3:] != ".m8":									# .m8 only !
			raise CompilerException("Source must be a .m8 file")
		if not os.path.isfile(sourceFile):								# must exist
			raise CompilerException("Cannot find file "+sourceFile)
		#print("Compiling "+sourceFile)
		src = open(sourceFile).readlines()								# work through the file
		for i in range(0,len(src)):
			ProjectCompiler.FILENAME = sourceFile						# set error info
			ProjectCompiler.LINENUMBER = i + 1
			if src[i][:6] == "import" or src[i][:4] == "uses":			# check for import <file> uses <lib>
				impFile = src[i].strip().split(" ")[1].lower()			# get the file.
				if src[i][:4] == "uses":
					compilerDir = os.path.dirname(os.path.abspath(__file__))
					impFile = compilerDir+os.sep+"lib"+os.sep+impFile
					impFile = impFile if impFile[-3:] == ".m8" else impFile+".m8"
					
				impBase = os.path.basename(impFile)						# just the base part
				if impBase not in self.imports:							# import it if we haven't already
					#print("importing "+impFile)
					self.compileFile(impFile)
					self.imports[impBase] = True
				self.dictionary.removeAllPrivate()
			else:
				self.lineCompiler.compile(src[i])
		self.LINENUMBER = 0
		#print("Compiled "+sourceFile)

if __name__ == "__main__":
	for src in sys.argv[1:]:
		print("M8C:Building "+src)		
		ProjectCompiler(src)

