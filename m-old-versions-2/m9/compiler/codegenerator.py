# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		codegenerator.py
#		Purpose:	M7 Compiler Code Generator
#		Date:		8th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from binary import *

# ****************************************************************************************
#								M15 Code Generator (Z80)
# ****************************************************************************************

class CodeGeneratorZ80(object):
	def __init__(self,binaryStore):
		self.store = binaryStore
	#
	#	Load a constant into A. This is a loader, so does A->B firest
	#
	def loadConstant(self,c):
		self.store.write1(0xEB)									# EX DE,HL (loader)
		self.store.write1(0x21)									# LD HL,xxxx
		self.store.write2(c)
	#
	#	Load address of string into A. This is a loader, so does A->B first. Reliant
	#	on loadConstant being 4 bytes long.
	#
	def loadStringConstant(self,str):
		self.loadConstant(self.store.getAddress()+4+2)			# code to load string addr as const
																# +6 is dependent on code size of loadconstant()
		self.store.write1(0x18)									# JR <over string>
		self.store.write1(len(str)+1)							# this is the +2													

		self.store.write1(len(str))								# string itself, length prefixed.
		for i in str:
			self.store.write1(ord(i) & 0x7F)
	#
	#	Generate word code. This can be a Z80 call or a Code Macro
	#
	def callWord(self,isMacro,address):
		if isMacro:
			size = self.store.read(address)						# length of macro
			if size > 7:										# seems very long ....
				raise CompilerException("Macro with more than 7 bytes ?")
			for i in range(0,size):								# copy macro in
				self.store.write1(self.store.read(address+i+1))
		else:
			self.store.write1(0xCD)								# CALL xxxx
			self.store.write2(address)
	#
	#	Load variable into A (Loader, so does A-> B first)
	#
	def loadVariable(self,address):
		self.store.write1(0xEB)									# EX DE,HL (loader)
		self.store.write1(0x2A)									# LD HL,(xxxx)
		self.store.write2(address)
	#
	#	Save A into variable (Not loader !)
	#
	def saveVariable(self,address):
		self.store.write1(0x22)									# LD (xxxx),HL
		self.store.write2(address)

if __name__ == "__main__":
	code = """
	//	This is a comment
	: main 4 -6 $42 "Hello world!"
	"is a " // comment again
	- 42 c@ @ 42 +!
		""".split("\n")

	binary = SpectrumSNA()
	dictionary = NamespaceDictionary()
	compiler = Compiler(binary,dictionary,CodeGeneratorZ80(binary))
	parser = WordParser(code,"(test code)")
	binary.echo = True
	compiler.compile(parser)
	binary.echo = False
