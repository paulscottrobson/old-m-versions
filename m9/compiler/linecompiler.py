# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		linecompiler.py
#		Purpose : 	Compiles a single line
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	22nd September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import re
from exceptions import *
from dictionary import *
from codegenerator import *
from kernel import *

# ***********************************************************************************************
#											Line Compiler Class
# ***********************************************************************************************

class LineCompiler(object):
	#
	#		Initialise
	#
	def __init__(self,kernel,codeGenerator):
		self.kernel = kernel
		self.codeGenerator = codeGenerator
		self.codeEnabled = True
	#
	#		Compile a singleline
	#
	def compileLine(self,line):
		line = line if line.find("//") < 0 else line[:line.find("//")]
		self.elements = [x for x in line.lower().replace("\t"," ").strip().split() if x != ""]
		self.nextElement = 0
		while self.nextElement < len(self.elements):
			self.compileElement(self.get())
	#
	#		Get next language element
	#
	def get(self):
		if self.nextElement >= len(self.elements):
			return ""
		self.nextElement += 1
		return self.elements[self.nextElement-1]
	#
	#		Compile a single element
	#
	def compileElement(self,word):
		print(">>>>",word)
		# 
		#		Define Word
		#
		if word == ":" or word == "::":
			name = self.get()
			if name == "":
				raise CompilerException("Definition name missing")
			self.codeEnabled = True
			if word == "::" and self.kernel.getDictionary().find(name) is not None:
				self.codeEnabled = False
			else:
				dItem = WordDictionaryItem(name,self.kernel.getCodePointer())
				self.kernel.getDictionary().add(dItem)
			return
		#
		if not self.codeEnabled:
			return
		#
		# 		Words of all types
		#
		di = self.kernel.getDictionary().find(word)
		if di is not None:
			di.generateCode(self.kernel,self.codeGenerator)
			return
		# 
		#		Variable
		#
		if word == "variable":
			name = self.get()
			if name == "":
				raise CompilerException("Definition name missing")
			self.kernel.getDictionary().addVariable(name,self.kernel.allocateData(2))
			return
		#			
		# TODO:Array type (and helper)
		#
		#
		# 		Control words
		#
		if word == "if" or word == "-if" or word == "then":
			if word == "if" or word == "-if":
				self.ifBranch = self.codeGenerator.compileBranch(self.kernel,"=0" if word == "if" else ">=0")
			else:
				self.codeGenerator.fixBranch(self.kernel,self.ifBranch,self.kernel.getCodePointer())
			return

		if word == "begin" or word == "until" or word == "-until":
			if word == "begin":
				self.beginLoop = self.kernel.getCodePointer()
			else:
				branch = self.codeGenerator.compileBranch(self.kernel,"=0" if word == "until" else ">=0")
				self.codeGenerator.fixBranch(self.kernel,branch,self.beginLoop)
			return

		if word == "for" or word == "i" or word == "next":
			self.codeGenerator.forCodeGenerator(self.kernel,word)
			return

		if word == ";":
			self.codeGenerator.compileReturn(self.kernel)
			return
		#
		# 		String constants
		#
		if word[0] == '"' and len(word) > 1:
			word = word[1:].replace("_"," ")
			self.codeGenerator.loadConstant(self.kernel,self.codeGenerator.compileString(self.kernel,word))
			return
		#
		# 		Numeric constants
		#
		c = self.convertInteger(word)
		if c is not None:
			self.codeGenerator.loadConstant(self.kernel,c)
			return
		#
		#		Give up
		#
		raise CompilerException("Do not understand word '{0}'".format(word))
	#
	#		Convert string to integer
	#
	def convertInteger(self,word):
		if re.match("^\-?[0-9]+$",word):
			return int(word) 
		if re.match("^\$[0-9a-f]+$",word):
			return int(word[1:],16) 
		return None

if __name__ == "__main__":	
	k = Type0Kernel("kernel.mbin")
	lc = LineCompiler(k,Z80CodeGenerator())
	code = """
	// this is a comment
	variable x
	:: nandx 42 42 42 
	: main 
	32 $13A2 
	x& x@ x!
	debug halt 
	if ; then
	4 begin -1 + -until
	10 for i next
	""".replace("\t"," ").split("\n")
	for c in code:
		lc.compileLine(c)
	k.exportSNA("test.sna")