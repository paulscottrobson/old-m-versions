# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		codegenerator.py
#		Purpose : 	Code Gemerator (Z80)
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	28th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

class Z80CodeGenerator(object):

	#
	#		Code to load A with a constant value with pre-swap
	#
	def loadConstant(self,kernel,const):
		self.swapAB(kernel)
		kernel.cByte(0x21)								# LD HL,nnnn
		kernel.cWord(const & 0xFFFF)
	#
	#		Code to load A with a variable value with pre-swap
	#
	def loadVariable(self,kernel,addr):
		self.swapAB(kernel)
		kernel.cByte(0x2A)								# LD HL,(nnnn)
		kernel.cWord(addr)
	#
	#		Code to save A to a variable 
	#
	def saveVariable(self,kernel,addr):
		kernel.cByte(0x22)								# LD (nnnn),HL
		kernel.cWord(addr)
	#
	#		Code to swap A+B
	#
	def swapAB(self,kernel):
		kernel.cByte(0xEB)								# EX DE,HL
	#
	#		Compile a string returning a reference
	#
	def compileString(self,kernel,str):
		kernel.cByte(0x18)								# JR rr
		kernel.cByte(len(str)+1)
		addr = kernel.getCodePointer()
		kernel.cByte(len(str))							# length
		for c in [ord(c) for c in str.upper()]:			# characters
			kernel.cByte(c & 0x3F)	
		return addr
	#
	#		Compile a call
	#
	def callRoutine(self,kernel,address):
		assert kernel.getCodePointer() >> 16 == address >> 16,"Different page code missing"
		kernel.cByte(0xCD)								# CALL xxxxx
		kernel.cWord(address)
	#
	#		Expand a macro
	#
	def expandMacro(self,kernel,address):
		size = kernel.read(address)
		if size == 0 or size > 6:
			raise CompilerException("Dubious macro size")
		for i in range(0,size):
			kernel.cByte(kernel.read(address+i+1))
	#
	#		Return from call
	#
	def compileReturn(self,kernel):
		kernel.cByte(0xC9)								# RET
	#
	#		Compile a branch
	#
	def compileBranch(self,kernel,brType):
		if brType == ">=0":
			kernel.cByte(0xCB)							# BIT 7,H
			kernel.cByte(0x7C)
			kernel.cByte(0xCA)							# JP Z,aaaa
		elif brType == "=0":
			kernel.cByte(0x7C)							# LD A,H
			kernel.cByte(0xB5)							# OR L
			kernel.cByte(0xCA)							# JP Z,aaaa
		elif brType == "#0":
			kernel.cByte(0x7C)							# LD A,H
			kernel.cByte(0xB5)							# OR L
			kernel.cByte(0xC2)							# JP NZ,aaaa
		else:
			assert "Bad test "+brType
		address = kernel.getCodePointer()
		kernel.cWord(0x0000)
		return address
	#
	#		Fix up a branch
	#
	def fixBranch(self,kernel,branchAddress,targetAddress):
		kernel.writeWord(branchAddress,targetAddress)
	#
	#		Code for for, next, loop
	#
	def forCodeGenerator(self,kernel,word):
		if word == "for":
			self.forLoopAddress = kernel.getCodePointer()
			kernel.cByte(0x2B)							# DEC HL
			kernel.cByte(0xE5)							# PUSH HL
		elif word == "next":
			kernel.cByte(0xE1)							# POP HL
			branch = self.compileBranch(kernel,"#0")	# Branch if non zero
			self.fixBranch(kernel,branch,self.forLoopAddress)
		elif word == "i":
			kernel.cByte(0xE1)							# POP HL
			kernel.cByte(0xE5)							# PUSH HL
		else:
			assert False
