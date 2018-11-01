# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		codegenerator.py
#		Purpose:	M7 Code Generator
#		Date:		24th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

# ****************************************************************************************
#								Z80 Code Generator
#
#			(to port to another CPU, the Core words need to be done as well)
# ****************************************************************************************

class Z80CodeGenerator(object):
	#
	#		Standard CPU Call to subroutine
	#
	def generateCPUCall(self,binary,address):
		binary.cByte(0xCD)										# $CD 	CALL
		binary.cWord(address & 0xFFFF)
	#
	#		Load a constant (loader, hence ex de,hl)
	#
	def loadConstant(self,binary,constant):
		binary.cByte(0xEB)										# $EB 	EX DE,HL
		binary.cByte(0x21)										# $21 	LD HL,xxxx
		binary.cWord(constant & 0xFFFF)
	#
	#		Load a variable (loader, hence ex de,hl)
	#
	def loadVariable(self,binary,address):
		binary.cByte(0xEB)										# $EB 	EX DE,HL
		binary.cByte(0x2A)										# $2A 	LD HL,(xxxx)
		binary.cWord(address & 0xFFFF)
	#
	#		Save a variable
	#
	def saveVariable(self,binary,address):
		binary.cByte(0x22)										# $2A 	LD (xxxx),HL
		binary.cWord(address & 0xFFFF)
	#
	#		Access an array element
	#
	def arrayAccess(self,binary,address):
		binary.cByte(0x29)										# $29   ADD HL,HL
		binary.cByte(0x01)										# $01 	LD BC,xxxx
		binary.cWord(address & 0xFFFF)
		binary.cByte(0x09)										# $09   ADD HL,BC
	#
	#		Copy code in (e.g. a macro)
	#
	def copyMacroCode(self,binary,size,addr):
		for i in range(0,size):
			binary.cByte(binary.readByte(addr+i))
	#
	#		Test and branch, without a branch address
	#
	def testBranch(self,binary,test):
		if test == "=0":
			binary.cByte(0x7C)
			binary.cByte(0xB5)
			binary.cByte(0x28)
			patch = binary.getPointer()
			binary.cByte(0x00)
		elif test == "#0":
			binary.cByte(0x7C)
			binary.cByte(0xB5)
			binary.cByte(0x20)
			patch = binary.getPointer()
			binary.cByte(0x00)
		elif test == ">=0":
			binary.cByte(0xCB)
			binary.cByte(0x7C)
			binary.cByte(0x28)
			patch = binary.getPointer()
			binary.cByte(0x00)
		else:
			assert False
		return patch
	#
	#		Complete a branch
	#
	def completeBranch(self,binary,target,address):
		binary.writeByte(target,(address - (target+1)) & 0xFF)

	#
	#		Code for FOR
	#
	def forCode(self,binary):
		binary.cByte(0x2B)											# dec HL
		binary.cByte(0xE5)											# push HL
	#
	#		Code for NEXT
	#
	def nextCode(self,binary,loopAddress):
		binary.cByte(0xE1)											# pop HL
		branch = self.testBranch(binary,"#0")						# test if NZ, go back if so
		self.completeBranch(binary,branch,loopAddress)
	#
	#		Code for I
	#
	def indexCode(self,binary):
		binary.cByte(0xE1)											# pop HL
		binary.cByte(0xE5)											# push HL
	#
	#		String Constant
	#
	def stringConstant(self,binary,string):
		binary.cByte(0x18)											# JR xx
		binary.cByte(len(string)+1)						
		stringAddr = binary.getPointer()							# where the string is
		binary.cByte(len(string))									# length byte
		for c in string:											# characters
			binary.cByte(ord(c))
		self.loadConstant(binary,stringAddr)						# and load the address in