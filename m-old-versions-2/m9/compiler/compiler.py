# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		compiler.py
#		Purpose:	M7 Compiler 
#		Date:		8th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from binary import *
from dictionary import *
from exceptions import *
from wordparser import *
from codegenerator import *

import re

# ****************************************************************************************
#										M15 Compiler
# ****************************************************************************************

class Compiler(object):
	#
	#		Set up
	#
	def __init__(self,binary,dictionary,codeGenerator):
		self.binary = binary
		self.dictionary = dictionary
		self.codeGenerator = codeGenerator
	#
	#		Compile source from parser object
	#
	def compile(self,parser):
		self.parser = parser
		# primarily chuck privates
		self.dictionary.resetNewSourceFile()
		# and work through it.
		token = self.parser.get()
		while token != "":
			self.compileWord(token)
			token = self.parser.get()
	#
	#		Compile a single word
	#
	def compileWord(self,word):
		if self.binary.echo:
			print("** Compiling '{0}' **".format(word))
		#
		# strings
		#
		if word[0] == '"' and word[-1] == '"' and len(word) >= 2:
			self.codeGenerator.loadStringConstant(word[1:-1])
			return
		word = word.lower()
		#
		# decimal constants
		#
		if re.match("^(\\-?[0-9]+)$",word):
			self.codeGenerator.loadConstant(int(word,10) & 0xFFFF)
			return
		#
		# hexadecimal constants
		#
		if re.match("^\\$(\\-?[0-9a-f]+)$",word):
			self.codeGenerator.loadConstant(int(word[1:],16) & 0xFFFF)
			return
		#
		# colon definitions
		#
		if word == ':':
			self.colonDefinition()
			return
		#
		# words,macros and variable address
		#
		item = self.dictionary.find(word)
		if item is not None:
			if isinstance(item,VariableDictionaryItem):
				self.codeGenerator.loadConstant(item.getAddress())
			else:
				self.codeGenerator.callWord(isinstance(item,MacroDictionaryItem),item.getAddress())
			return
		#
		# variable load and store
		#
		if (word[-1] == '@' or word[-1] == "!") and len(word) > 1:
			item = self.dictionary.find(word[:-1])
			if item is not None and isinstance(item,VariableDictionaryItem):
				if word[-1] == '@':
					self.codeGenerator.loadVariable(item.getAddress())
				else:
					self.codeGenerator.saveVariable(item.getAddress())
				return
		#
		# variable definitions, array defintions [check variable load/store/addr work !!]
		#
		if word == "variable" or word == "array":
			self.createVariable(word == "variable")
			return
		#
		# private and bank switches.
		#
		#
		# namespacing and using
		#
		#
		# structures if, begin, while, for
		#
		raise CompilerException("Don't understand '{0}'".format(word))
	#
	#		Handle Colon Definitions e.g. : <name>
	#
	def colonDefinition(self):
		defWord = self.parser.get().lower()
		if defWord == "":
			raise CompilerException(": missing word name")
		newItem = WordDictionaryItem(defWord,self.binary.getAddress())
		if self.binary.echo:
			print("Adding "+newItem.toString())
		self.dictionary.add(newItem)
		if defWord == "main":
			self.binary.setMain(self.binary.getAddress())
			if self.binary.echo:
				print("Updating main() pointer")
	#
	#		Variable or array definition
	#
	def createVariable(self,isVariable):
		defWord = self.parser.get().lower()
		if defWord == "":
			raise CompilerException("variable missing word name")
		if isVariable:
			newItem = VariableDictionaryItem(defWord,self.binary.getAddress())
		else:
			newItem = ArrayDictionaryItem(defWord,self.binary.getAddress())
		if self.binary.echo:
			print("Adding "+newItem.toString())
		self.dictionary.add(newItem)
		if isVariable:
			self.binary.write2(0x0000)
		else:
			size = self.parser.get().lower()
			if re.match("^[0-9]+$",size):
				size = int(size,10)
			elif re.match("^\$[0-9a-f]+$",size):
				size = int(size[1:],16)
			else:
				raise CompilerException("Bad array size "+size)
			for i in range(0,size):
				self.binary.write1(0x00)

if __name__ == "__main__":
	code = """
	//	This is a comment
	: main 
	1 con.paper	2 con.ink  	 
		$22 0 con.screen!  
		2 con.ink $42 2 con.screen!  
		3 con.ink $62 4 con.screen!  
		4 con.ink $A2 6 con.screen!  
	$123A $45EF debug halt ;
		""".split("\n")

	binary = SpectrumSNA()
	dictionary = NamespaceDictionary()
	compiler = Compiler(binary,dictionary,CodeGeneratorZ80(binary))
	parser = WordParser(code,"(test code)")
	binary.echo = False
	compiler.compile(parser)
	binary.echo = False
	binary.writeBinary("test")
	