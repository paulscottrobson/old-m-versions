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

from exceptions import *
from dictionary import *
import sys

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
		self.controlAction(binary,dictionary,wordSource,codeGenerator)
	def set(self,key,value):
		BaseControlDictionaryItem.store[key.lower().strip()] = value
	def get(self,key):
		key = key.lower().strip()
		return BaseControlDictionaryItem.store[key] if key in BaseControlDictionaryItem.store else None

BaseControlDictionaryItem.store = {}

# ****************************************************************************************
#										Colon
# ****************************************************************************************


class ColonControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		definitionName = wordSource.getWord().lower()
		if definitionName == "":
			raise CompilerException("Missing definition name")
		if binary.echo is not None:
			binary.echo.write("===== {0} =====\n".format(definitionName))
		wordDefinition = WordDictionaryItem(definitionName,binary.getPointer())
		dictionary.addDictionaryItem(wordDefinition)
		if definitionName == "main":
			binary.setMainAddress(binary.getPointer())

class DoubleColonControlDictionaryItem(ColonControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		definitionName = wordSource.getWord().lower()
		if definitionName == "":
			raise CompilerException("Missing definition name")
		if binary.echo is not None:
			binary.echo.write("===== {0} =====\n".format(definitionName))
		if dictionary.find(definitionName) is not None:
			wordSource.compileAllowed = False
		else:
			wordSource.compileAllowed = True
			wordDefinition = WordDictionaryItem(definitionName,binary.getPointer())
			dictionary.addDictionaryItem(wordDefinition)
			if definitionName == "main":
				binary.setMainAddress(binary.getPointer())

# ****************************************************************************************
#									if/-if/then
# ****************************************************************************************

class IfDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		self.set("ifAddress",codeGenerator.testBranch(binary,"=0"))

class MinusIfDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		self.set("ifAddress",codeGenerator.testBranch(binary,">=0"),binary.getPointer())

class ThenDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		codeGenerator.completeBranch(binary,self.get("ifAddress"),binary.getPointer())

# ****************************************************************************************
#									begin/until/-until
# ****************************************************************************************

class BeginDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		self.set("beginAddress",binary.getPointer())

class UntilDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		branch = codeGenerator.testBranch(binary,"=0")
		codeGenerator.completeBranch(binary,branch,self.get("beginAddress"))		

class MinusUntilDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		branch = codeGenerator.testBranch(binary,">=0")
		codeGenerator.completeBranch(binary,branch,self.get("beginAddress"))		

# ****************************************************************************************
#									for/next/i
# ****************************************************************************************

class ForDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		self.set("forAddress",binary.getPointer())
		codeGenerator.forCode(binary)

class IndexDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		codeGenerator.indexCode(binary)

class NextDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		codeGenerator.nextCode(binary,self.get("forAddress"))

# ****************************************************************************************
#									Variable
# ****************************************************************************************

class VariableControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		varName = wordSource.getWord().lower()
		if varName == "":
			raise CompilerException("Missing variable name")
		wordDefinition = VariableDictionaryItem(varName,binary.getPointer())
		dictionary.addDictionaryItem(wordDefinition)
		binary.cWord(0)

# ****************************************************************************************
#									Variable
# ****************************************************************************************

class ArrayControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		varName = wordSource.getWord().lower()
		if varName == "":
			raise CompilerException("Missing array name")
		size = wordSource.evaluateConstant(wordSource.getWord())
		if size is None or size == 0:
			raise CompilerException("Bad or missing array size")
		wordDefinition = ArrayDictionaryItem(varName,binary.getPointer())
		dictionary.addDictionaryItem(wordDefinition)
		for i in range(0,size):
			binary.cByte(0)

# ****************************************************************************************
#									Listing Control
# ****************************************************************************************

class ListControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		ctrl = wordSource.getWord().lower()
		if ctrl != "on" and ctrl != "off":
			raise CompilerException("list must be followed by on or off")
		binary.echo = None if ctrl == "off" else sys.stdout

# ****************************************************************************************
#								Make last definition private
# ****************************************************************************************

class PrivateControlDictionaryItem(BaseControlDictionaryItem):
	#
	def controlAction(self,binary,dictionary,wordSource,codeGenerator):
		dictionary.makeLastPrivate()

# ****************************************************************************************
#						Class which returns list of Control Instances
# ****************************************************************************************

class ControlList(object):
	def getControlList(self):
		return [
			ColonControlDictionaryItem(":"),
			DoubleColonControlDictionaryItem("::"),
			IfDictionaryItem("if"),
			MinusIfDictionaryItem("-if"),
			ThenDictionaryItem("then"),
			BeginDictionaryItem("begin"),
			UntilDictionaryItem("until"),
			MinusUntilDictionaryItem("-until"),
			ForDictionaryItem("for"),
			NextDictionaryItem("next"),
			IndexDictionaryItem("i"),
			VariableControlDictionaryItem("variable"),
			ArrayControlDictionaryItem("array"),
			ListControlDictionaryItem("list"),
			PrivateControlDictionaryItem("private")
		]
		