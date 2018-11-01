# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		m6c.py
#		Purpose:	Simple M6 Compiler.
#		Date:		15th August 2018
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
			self.binary[0x5B00 + i] = core[i]
		self.lastWritten = 0x5B00 + len(core)								# last byte written
		dic = [x for x in mlib.getDictionary() if x.find("system.info")>=0] # extract sysinfo entry
		self.systemInfo = int(dic[0].split("__")[2])						# rip from dictionary
		self.codePtr = self.read(self.systemInfo+2)+self.read(self.systemInfo+3) * 256
		self.echo = False
	#
	#			Accessors and Mutators
	#
	def read(self,addr):													# access/mutate
		return self.binary[addr]
	def write(self,addr,data):
		self.lastWritten = max(self.lastWritten,addr)
		data = data & 0xFF
		self.binary[addr] = data
		if self.echo:
			print("\t{0:04x} : {1:02x} {2:c}".format(addr,data,((data & 0x3F) ^ 0x20) + 0x20))
	def cByte(self,data):													# compile a byte
		self.write(self.codePtr,data)
		self.codePtr += 1
	def cWord(self,data):
		self.cByte(data & 0xFF)
		self.cByte(data >> 8)
	#
	#			Set the start address
	#
	def setMain(self,mainAddress):
		self.write(self.systemInfo+6,mainAddress & 0xFF)					# word main updates start
		self.write(self.systemInfo+7,mainAddress >> 8)						# address.
	#
	#			Write a memory block.
	#
	def writeMemory(self,handle,fromAddr,toAddr):
		self.write(self.systemInfo+2,self.codePtr & 0xFF) 					# update code pointer
		self.write(self.systemInfo+3,self.codePtr >> 8)
		handle.write(bytes(self.binary[fromAddr:toAddr]))					# and write out
	#
	#			Generate a snap or some other loading file.
	#
	def generateSnapFile(self,stub):
		oldPointer = self.codePtr											# save code pointer
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
		self.codePtr = oldPointer
		self.write(0x5AFE,0x00)												# put start $5B00 at
		self.write(0x5AFF,0x5B)												# TOS.
		h = open(stub+".sna","wb")											# write as a snap file.
		self.writeMemory(h,0x4000-27,0x10000)
		h.close()

# ****************************************************************************************
#								   Dictionary Class
# ****************************************************************************************

class Dictionary(object):
	def __init__(self):
		core = MSystemLibrary().getDictionary()								# get dictionary list
		self.words = {}														# create the initial library.
		for c in core:
			c = c.split("__")
			self.add(c[0],c[1],int(c[2]))
	#
	#			Add in a new entry
	#
	def add(self,name,type,address):
		name = name.lower().strip()											# tidy up
		type = type.lower().strip()
		if name in self.words:												# check duplicates
			raise CompilerException("Duplicate name "+name)
		self.words[name] = { "name":name,"type":type,"address":address,"private":type == "variable" }
		self.words[name]["immediate"] = type == "macro"						# macros are immediates
		self.last = self.words[name]										# remember last definition
	#
	#			Apply "Private" and "Immediate" to last word
	#
	def makeLastPrivate(self):												# make last defined private
		self.last["private"] = True
	def makeLastImmediate(self):											# make last defined immediate
		self.last["immediate"] = True
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
	#			Output the whole dictionary into memory
	#
	def createInMemory(self,binary):
		#binary.echo = True	
																			# start of dictionary
		dp = binary.read(binary.systemInfo+10)+binary.read(binary.systemInfo+11) * 256
		words = [x for x in self.words.keys()]								# words to do in memory
		words.sort(key = lambda x:self.words[x]["address"])					# order
		for w in words:
			binary.write(dp+0,len(w)+5)										# +0 : offset to next
			binary.write(dp+1,self.words[w]["address"] & 0xFF)				# +1 : address low
			binary.write(dp+2,self.words[w]["address"] >> 8)				# +2 : adddress high
			binary.write(dp+3,0)											# +3 : page number
			cByte = len(w) + (0x80 if self.words[w]["immediate"] else 0x00)
			binary.write(dp+4,cByte) 										# +4 : length (0..4)
																			#    : private (6)
																			# 	 : immediate (7)
			for i in range(0,len(w)):										# +5 : name in 6 bit ASCII
				binary.write(dp+5+i,ord(w[i].upper()) & 0x3F)			

			dp = dp + len(w) + 5											# next memory area

		binary.write(dp,0)													# offset byte 0, end.
		binary.write(binary.systemInfo+0,dp & 0xFF)							# update dict next free
		binary.write(binary.systemInfo+1,dp >> 8)
		#binary.echo = False 

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
		line = line.replace("\t"," ").strip()								# remove tabs amd stro[ ot/]
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
		#		Handle comments.
		#
		if word == "(*" or word == "*)":
			self.inComment = (word == "(*")
			return
		if self.inComment:
			return
		if self.binary.echo:
			print("{0}".format(word))
		#
		#		Integer constant
		#
		intNum = self.wordToNumber(word)
		if intNum is not None:
			self.compileConstant(intNum)
			return		
		#
		#		String constant
		#
		if word[0] == '"' and word[-1] == '"' and len(word) >= 2:		# string constant
			self.binary.cByte(0xEB) 									# ex de,hl
			self.binary.cByte(0x21)										# LD HL, <string start>
			self.binary.cWord(self.binary.codePtr+4)
			self.binary.cByte(0x18)										# JR <over string>
			self.binary.cByte(len(word)-1)
			self.binary.cByte(len(word)-2)								# length of string
			for c in word[1:-1].replace("_"," ").upper():
				self.binary.cByte(((ord(c) & 0x3F) ^ 0x20) + 0x20)
			return
		#
		#		Colon Definition
		#
		if word == ':' :												# colon definition
			newWord = self.getNextWord()
			if newWord == "":
				raise CompilerException(": without word name")
			if self.binary.echo:
				print(" **** "+newWord+" ****")
			self.dictionary.add(newWord,"word",self.binary.codePtr)
			if newWord == "main":
				self.binary.setMain(self.binary.codePtr)
			return
		#
		#		Words (Macro/Immediate AND direct)
		#
		wRec = self.dictionary.find(word)								# words
		if wRec is not None:
			if wRec["type"] == "word":
				if wRec["immediate"]:
					raise CompilerException(word+" is immediate, call cannot be compiled.")
				self.binary.cByte(0xCD)									# call <addr>
				self.binary.cWord(wRec["address"])
			if wRec["type"] == "macro":
				addr = wRec["address"]+3								# skip over the call MacroExpand
				size = self.binary.read(addr)							# to size, followed by data
				assert size >= 0 and size <= 6,"Macro size ? "+word
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
			if word[-1] == '#':											# array (address + A * 2)
				self.binary.cByte(0x29)									# add hl,hl (double index)
				self.binary.cByte(0x01)									# ld bc,address
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
		if word == "for" or word == "next":
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
		if word == "list.on" or word == "list.off":						# control code listing
			self.binary.echo = (word == "list.on")
			return
		if word == "variable":											# 2 byte variable
			self.dictionary.makeLastPrivate()
			self.binary.cWord(0)
			return
		if word == "array":												# array of byte size
			self.dictionary.makeLastPrivate()
			size = self.wordToNumber(self.getNextWord())				# get size of array
			if size is None:
				raise CompilerException("Array without valid size")
			for i in range(0,size):
				self.binary.cByte(0)
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
		self.binary.cByte(0xEB) 										# ex de,hl
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
		else:
			self.binary.cByte(0xE1)										# pop HL
			self.binary.cWord(0xB57C)									# test if zero
			self.binary.cByte(0x20)										# if nz
			self.binary.cByte(self.forAddress-(self.binary.codePtr+1))

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
			print("*** M6 Error *** {0}:{1} .... {2}".format(ProjectCompiler.FILENAME,ProjectCompiler.LINENUMBER,err.message))
			sys.exit(1)

		self.dictionary.removeAllPrivate()								# remove all private words		
		self.dictionary.createInMemory(self.binary)						# generate directory in memory		
		self.binary.generateSnapFile(sourceFile[:-3])					# generate SNA file.
	#
	#			Compile a single file
	#
	def compileFile(self,sourceFile):
		if sourceFile[-3:] != ".m6":									# .m6 only !
			raise CompilerException("Source must be a .m6 file")
		if not os.path.isfile(sourceFile):								# must exist
			raise CompilerException("Cannot find file "+sourceFile)
		src = open(sourceFile).readlines()								# work through the file
		for i in range(0,len(src)):
			ProjectCompiler.FILENAME = sourceFile						# set error info
			ProjectCompiler.LINENUMBER = i + 1
			if src[i][:6] == "import":									# check for import <file>
				impFile = src[i][6:].strip().split(" ")[0].lower()		# get the file.
				if impFile not in self.imports:							# import it if we haven't already
					self.compileFile(impFile)
					self.imports[impFile] = True
				self.dictionary.removeAllPrivate()
			else:
				self.lineCompiler.compile(src[i])
		self.LINENUMBER = 0

if __name__ == "__main__":
	for src in sys.argv[1:]:
		print("M6C:Building "+src)		
		ProjectCompiler(src)
