# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		dictionary.py
#		Purpose:	M7 Compiler Dictionary/Namespace
#		Date:		8th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from m_runtime import *
from exceptions import *

# ****************************************************************************************
#								Dictionary Item classes
# ****************************************************************************************

class DictionaryItem(object):
	#
	def __init__(self,name,address):
		self.name = name.strip().lower()
		self.address = address
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

class WordDictionaryItem(DictionaryItem):
	def toString(self):
		return "WRD:{0:04x}:{1}".format(self.getAddress(),self.getName())

class MacroDictionaryItem(DictionaryItem):
	def toString(self):
		return "MAC:{0:04x}:{1}".format(self.getAddress(),self.getName())		

class VariableDictionaryItem(DictionaryItem):
	def toString(self):
		return "VAR:{0:04x}:{1}".format(self.getAddress(),self.getName())				

# ****************************************************************************************
#									Dictionary Class
# ****************************************************************************************

class Dictionary(object):

	def __init__(self):
		self.dictionary = {}
		self.last = None
		for word in MRuntime().getDictionary():
			word = word.lower().split("::")
			if word[1] == "macro":
				self.dictionary[word[0]] = MacroDictionaryItem(word[0],int(word[2],16))
			elif word[1] == "word" or word[1] == "slow":
				self.dictionary[word[0]] = WordDictionaryItem(word[0],int(word[2],16))			
			elif word[1] == "variable":
				self.dictionary[word[0]] = VariableDictionaryItem(word[0],int(word[2],16))			
			else:
				assert False,word
	#
	#	Show dictionary
	#
	def show(self):
		keys = [x for x in self.dictionary]
		keys.sort()
		for k in keys:
			print(self.dictionary[k].toString())
	#
	#	Add to the dictionary
	#
	def add(self,item):
		key = item.getName().lower()
		if key in self.dictionary:
			raise CompilerException("Duplicate identifier "+key)
		self.dictionary[key] = item
		self.last = item
	#
	#	Find entry or None if it doesn't exist
	#
	def find(self,name):
		name = name.strip().lower()
		return None if name not in self.dictionary else self.dictionary[name]
	#
	#	New source file : remove all privates
	#
	def resetNewSourceFile(self):
		newDict = {}
		for k in self.dictionary.keys():
			if not self.dictionary[k].isPrivate():
				newDict[k] = self.dictionary[k]
		self.dictionary = newDict
	#
	#	Make last private
	#
	def makeLastPrivate(self):
		if self.last is not None:
			self.last.makePrivate()
			self.last = None

# ****************************************************************************************
#							Namespaced Dictionary Class
# ****************************************************************************************

class NamespaceDictionary(object):

	def __init__(self):
		self.dictionary = Dictionary()
		self.resetNewSourceFile()
	#
	#	Show dictionary
	#
	def show(self):
		self.dictionary.show()
	#
	#	Add to the dictionary
	#
	def add(self,item):
		if self.nameSpace is None:
			self.dictionary.add(item)
			return
		newName = self.nameSpace.strip().lower()+"."+item.getName()
		if isinstance(item,WordDictionaryItem):
			self.dictionary.add(WordDictionaryItem(newName,item.getAddress()))
		elif isinstance(item,MacroDictionaryItem):
			self.dictionary.add(MacroDictionaryItem(newName,item.getAddress()))
		elif isinstance(item,VariableDictionaryItem):
			self.dictionary.add(VariableDictionaryItem(newName,item.getAddress()))
		else:
			assert False
	#
	#	Find entry or None if it doesn't exist
	#
	def find(self,name):
		# first look under name on own
		direct = self.dictionary.find(name)
		if direct is not None:
			return direct
		# 
		for prefix in self.usingList:
			pFind = self.dictionary.find(prefix+"."+name)
			if pFind is not None:
				return pFind
		return None
	#
	#	New source file : resets all values
	#
	def resetNewSourceFile(self):
		self.dictionary.resetNewSourceFile()
		self.usingList = []
		self.nameSpace = None
	#
	#	Make last private
	#
	def makeLastPrivate(self):
		self.dictionary.makeLastPrivate()
	#
	#	Set current namespace (reset by resetNewSourceFile())
	#
	def setNameSpace(self,ns):
		self.nameSpace = ns
	#
	#	Add a 'using' namespace e.g. one to search
	#
	def addUsingPrefix(self,using):
		self.usingList.append(using.strip().lower())

if __name__ == "__main__":
	d = NamespaceDictionary()
	d.setNameSpace("test1")
	d.addUsingPrefix("test2")
	d.addUsingPrefix("test1")
	d.add(WordDictionaryItem("zzzup",0x1234))
	print("--------")
	print(d.find("debug").toString())
	print(d.find("FALSE").toString())
	print(d.find("zzzup").toString())
	d.makeLastPrivate()
	#d.resetNewSourceFile()
	d.show()
	print("--------")
