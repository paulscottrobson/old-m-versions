# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		dictionary.py
#		Purpose:	M7 Dictionary and Dictionary Item Classes
#		Date:		26th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from exceptions import *
from msystem import *


# ****************************************************************************************
#								Dictionary Item Classes
# ****************************************************************************************

class DictionaryItem(object):
	#
	def __init__(self,name,pageAddress):
		self.name = name.strip().lower()
		self.address = pageAddress
		self.private = False
	#
	def getName(self):
		return self.name
	def getAddress(self):
		return self.address
	def isPrivate(self):
		return self.private
	#
	def makePrivate(self):
		self.private = True
	#
	def codeGenerate(self,binary,dictionary,wordSource,codeGenerator,modifier = ""):
		testMod = "X" if modifier == "" else modifier 						# X we use for no modifier e.g. call
		if self.getAcceptableModifiers().find(testMod) < 0:				# reject unsuitable types.
			raise CompilerException("Cannot do modifier '{0}' for {1}".format(modifier,self.name))
		if modifier == "":													# call
			codeGenerator.generateCPUCall(binary,self.getAddress())
		elif modifier == "&":												# load addr
			codeGenerator.loadConstant(binary,self.getAddress())
		elif modifier == "@":												# load var
			codeGenerator.loadVariable(binary,self.getAddress())
		elif modifier == "!":												# save var
			codeGenerator.saveVariable(binary,self.getAddress())
		elif modifier == "#":												# array access
			codeGenerator.arrayAccess(binary,self.getAddress())
		else:
			assert False,"Unknown modifier '"+modifier+"'"					# ????
	#
	def toString(self):
		s = "{2} {0} @ ${1:04x} ".format(self.name,self.address,self.getTypeName())
		s += "PR" if self.isPrivate() else ""
		return s
	#
	def getTypeName(self):
		return "BASE"

# ****************************************************************************************
#									Normal called Word
# ****************************************************************************************

class WordDictionaryItem(DictionaryItem):
	def getTypeName(self):
		return "WORD"
	def getAcceptableModifiers(self):
		return "X&"

# ****************************************************************************************
#						Core Macro (cannot generate macros elsewhere)
# ****************************************************************************************

class MacroDictionaryItem(DictionaryItem):
	def getTypeName(self):
		return "MACRO"
	def getAcceptableModifiers(self):
		return "X"
	def codeGenerate(self,binary,dictionary,wordSource,codeGenerator,modifier = ""):
		if modifier != "":
			raise CompilerException("Cannot modify word '{0}' as it is a code macro".format(self.getName()))
		addr = self.getAddress()
		size = binary.readByte(addr)											# get length of macro
		assert size > 0 and size <= 7,"Bad macro length {0} {1}".format(size,self.getName())
		codeGenerator.copyMacroCode(binary,size,addr+1)

# ****************************************************************************************
#										Variable 
# ****************************************************************************************

class VariableDictionaryItem(DictionaryItem):
	def getTypeName(self):
		return "VAR"
	def getAcceptableModifiers(self):
		return "&!@"
	def isPrivate(self):
		return True


# ****************************************************************************************
#										 Array
# ****************************************************************************************

class ArrayDictionaryItem(DictionaryItem):
	def getTypeName(self):
		return "ARRAY"
	def getAcceptableModifiers(self):
		return "&#"
	def isPrivate(self):
		return True

# ****************************************************************************************
#										Dictionary Class
# ****************************************************************************************

from control import *	

class Dictionary(object):
	#
	#	Initialise
	#
	def __init__(self):
		self.dictionary = {}
		for dEntry in MSystemLibrary().getDictionary():
			dEntry = dEntry.split("__")
			if dEntry[1] == "macro":
				newItem = MacroDictionaryItem(dEntry[0],int(dEntry[2]))
			else:
				newItem = WordDictionaryItem(dEntry[0],int(dEntry[2]))
			self.addDictionaryItem(newItem)
		for cItem in ControlList().getControlList():
			self.addDictionaryItem(cItem)
	#
	#	Add a dictionary item.
	#
	def addDictionaryItem(self,item):
		if item.getName() in self.dictionary:
			raise CompilerException("Word '{0}' redefined.".format(item.getName()))
		self.dictionary[item.getName()] = item
		self.lastEntry = item
	#
	#	Modifiers
	#
	def makeLastPrivate(self):
		self.lastEntry.makePrivate()
	#
	#	Remove private entries from dictionary
	#
	def purgePrivateDictionaryEntries(self):
		words = self.dictionary
		self.dictionary = {}
		for k in words.keys():
			if not words[k].isPrivate():
				self.dictionary[k] = words[k]
	#
	#	Find a dictionary word
	#
	def find(self,word):
		word = word.strip().lower()
		return self.dictionary[word] if word in self.dictionary else None

if __name__ == '__main__':
	d = Dictionary()
	print(d.dictionary.keys())
	d.purgePrivateDictionaryEntries()	
	for k in d.dictionary.keys():
		print(k,"..",d.dictionary[k].toString()	)
	print("---------------------------------------------")
	print(d.find("not").toString())

