# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		dictionary.py
#		Purpose : 	Dictionary Object
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	28th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

from exceptions import *
import os

# ***********************************************************************************************
#									Dictionary Item Classes
# ***********************************************************************************************

class DictionaryItem(object):
	def __init__(self,name,address):
		self.name = name.strip().lower()
		self.address = address
		self.private = False
	def getName(self):
		return self.name
	def getAddress(self):
		return self.address
	def isPrivate(self):
		return self.private
	def makePrivate(self):
		self.private = True
	def generateCode(self,codeStore,codeGenerator):
		assert False
	def getExportName(self):
		assert False

class MacroDictionaryItem(DictionaryItem):
	def generateCode(self,codeStore,codeGenerator):
		codeGenerator.expandMacro(codeStore,self.getAddress())
	def getExportName(self):
		return "&&"+self.name

class WordDictionaryItem(DictionaryItem):
	def generateCode(self,codeStore,codeGenerator):
		codeGenerator.callRoutine(codeStore,self.getAddress())
	def getExportName(self):
		return self.name

class VarLoadDictionaryItem(DictionaryItem):
	def generateCode(self,codeStore,codeGenerator):
		codeGenerator.loadVariable(codeStore,self.getAddress())

class VarSaveDictionaryItem(DictionaryItem):
	def generateCode(self,codeStore,codeGenerator):
		codeGenerator.saveVariable(codeStore,self.getAddress())

class VarAddressDictionaryItem(DictionaryItem):
	def generateCode(self,codeStore,codeGenerator):
		codeGenerator.loadConstant(codeStore,self.getAddress())

# ***********************************************************************************************
#										Dictionary class
# ***********************************************************************************************

class Dictionary(object):
	#
	#		Initialise, load in .mref file.
	#
	def __init__(self,refFile = "clean"+os.sep+"boot.dict"):
		self.contents = {}								# Hash of words and macros
		self.lastAdded = None
														# Scan source file
		for x in [x.strip() for x in open(refFile).readlines() if x.strip() != ""]:
			x = x.split(":=$")							# split into two bits
			address = int(x[1],16)
			if len(x[0]) > 2 and x[0][:2] == "&&":		# macro
				self.add(MacroDictionaryItem(x[0][2:],address))
			else: 										# word
				self.add(WordDictionaryItem(x[0],address))
	#
	#		Get Base Address, System Info Table
	#
	def getBaseAddress(self):
		return 0x8000
	def getSystemInfo(self):
		return 0x8004
	#
	#		Add item to dictionary
	#
	def add(self,item):
		if item.getName() in self.contents:
			raise CompilerException(self.contents,item.getName()+" present twice.")
		self.contents[item.getName()] = item
		self.lastAdded = item
	#
	#		Add variable to dictionary, creates three private accessors
	#
	def addVariable(self,stem,address):
		item = VarLoadDictionaryItem(stem+"@",address)
		item.makePrivate()
		self.add(item)
		item = VarSaveDictionaryItem(stem+"!",address)
		item.makePrivate()
		self.add(item)
		item = VarAddressDictionaryItem(stem+"&",address)
		item.makePrivate()
		self.add(item)
	#
	#		Remoe all private items
	#
	def removePrivateItems(self):
		hash = self.contents
		self.contents = {}
		for k in hash.keys():
			if not hash[k].isPrivate():
				self.contents[k] = hash[k]
		hash = None
	#
	#		Make last private
	#
	def makeLastPrivate(self):
		self.lastAdded.makePrivate()	
	#
	#		Find element by name.
	#
	def find(self,key):
		key = key.strip().lower()
		return self.contents[key] if key in self.contents else None
	#
	#		Write out dictionary to target file
	#
	def save(self,fileName = "boot.dict"):
		self.removePrivateItems()
		h = open(fileName,"w")
		keys = [x for x in self.contents.keys()]
		keys.sort(key = lambda x:self.contents[x].getAddress())
		for k in keys:
			h.write("{0}:=${1:06x}\n".format(self.contents[k].getExportName(), \
											 self.contents[k].getAddress()))
		h.close()

if __name__ == "__main__":
	d = Dictionary()
	print("{0:04x}".format(d.getBaseAddress()))
	d.addVariable("dv",1024)
	print(d.contents.keys())
	d.removePrivateItems()
	print(d.contents.keys())
	d.save()
	