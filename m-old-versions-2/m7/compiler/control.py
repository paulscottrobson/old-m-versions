# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		control.py
#		Purpose:	M7 Control word Dictionary items
#		Date:		24th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from dictionary import *
from exceptions import *
	
# ****************************************************************************************
#								Base item for control objects
#
#	These are action words : variable array if next and so on that do something out of
#	the ordinary when compiling.
# ****************************************************************************************

class BaseControlDictionaryItem(DictionaryItem):
	def __init__(self,name):
		DictionaryItem.__init__(self,name,0x0000)
	def getAcceptableModifiers(self):
		return "X"
	def getTypeName(self):
		return "CONTROL"
	def isImmediate(self):
		return True
	def codeGenerate(self,binary,dictionary,wordSource,codeGenerator,modifier = ""):
		if modifier != "":
			raise CompilerException("Cannot modify word '{0}' as it is a control word".format(self.getName()))
		self.controlAction(binary,dictionary,wordsource,codeGenerator)

# ****************************************************************************************
#										Colon
# ****************************************************************************************

class ColonControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		# get name
		# validate it
		# create new entry
		# if main update binary.




def getControlList():
	return [
		ColonControlDictionaryItem(":")
	]