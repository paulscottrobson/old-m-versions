# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		linecompiler.py
#		Purpose:	M7 Line Compiler
#		Date:		26th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from dictionary import *
from exceptions import *
from binary import *
from codegenerator import *
import re

# ****************************************************************************************
#									Line Compiler Class
# ****************************************************************************************

class LineCompiler(object):
	#
	#		Set up, creating objects if needed
	#
	def __init__(self,binary,dictionary = Dictionary(),codeGenerator = Z80CodeGenerator()):
		self.binary = binary
		self.dictionary = dictionary
		self.codeGenerator = codeGenerator
		self.compileAllowed = True
	#
	#		Compile a single line
	#
	def compile(self,line):
		line = line.replace("\t"," ")								# Process tabs and comments
		line = line if line.find("//") < 0 else line[:line.find("//")]
																	# Divide into words
		self.lineSource = [x.strip() for x in line.split(" ") if x.strip() != ""]
		self.lsIndex = 0
		while self.lsIndex < len(self.lineSource):					# While more words
			self.compileItem(self.getWord())						# Compile the next one
	#
	#		Get a word from the word line queue, return "" if none left
	#
	def getWord(self):
		if self.lsIndex == len(self.lineSource):
			return ""
		self.lsIndex += 1
		return self.lineSource[self.lsIndex-1]
	#
	#		Compile a single word
	#
	def compileItem(self,word):
		#
		#		Check if compilation is disabled.
		#
		if word != "::" and not self.compileAllowed:				# :: always executes
			return													# other can be disabled

		if self.binary.echo is not None:							# listing information
			self.binary.echo.write("[[{0}]]\n".format(word.lower()))
		#
		#		Check string constant
		#
		if len(word) >= 2 and word[0] == '"' and word[-1] == '"':
			self.codeGenerator.stringConstant(self.binary,word[1:-1].replace("_"," "))
			return
		# 
		#		Check numeric constant
		#
		const = self.evaluateConstant(word)
		if const is not None:
			self.codeGenerator.loadConstant(self.binary,const)
			return
		#
		#		Check unmodified word
		#
		wDef = self.dictionary.find(word)
		if wDef is not None:
			wDef.codeGenerate(self.binary,self.dictionary,self,self.codeGenerator,"")
			return
		#
		#		Check modified word
		#
		if len(word) > 1 and "&!#@".find(word[-1]) >= 0:
			wDef = self.dictionary.find(word[:-1])
			if wDef is not None:
				wDef.codeGenerate(self.binary,self.dictionary,self,self.codeGenerator,word[-1])
				return

		raise CompilerException("Do not understand '{0}'".format(word))
	#
	#		Evaluate word as a numeric constant
	#
	def evaluateConstant(self,word):
		m = re.match("^\-?\d+$",word)
		if m is not None:
			return int(word,10) & 0xFFFF
		m = re.match("^\$[0-9a-fA-F]+$",word)
		if m is not None:
			return int(word[1:],16) & 0xFFFF
		return None

if __name__ == '__main__':
	binary = Spectrum48kSNA()	
	lcom = LineCompiler(binary)

	test = """
		: main 
		breakpoint 
		"hello_world" 
		array a1 6 a1& a1# 
		variable v1 v1@ v1& v1! 
		10 for i next 
		: x 42 $1FF x
		and and& true 
		main breakpoint + halt 
		begin 1 until begin 1 -until 
		if 1 then if -1 then 
		:: x1 42 ;
		:: y1 43 ;
		// comment
	"""
	test= test.replace("\n"," ").replace("\t"," ")
	lcom.compile(test)
	binary.save("test")