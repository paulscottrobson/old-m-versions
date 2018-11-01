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
	def saveVariable(self,binary.address):
		binary.cByte(0x22)										# $2A 	LD (xxxx),HL
		binary.cWord(address & 0xFFFF)
	#
	#		Access an array element
	#
	def arrayAccess(self,binary,address):
		binary.cByte(0x29)										# $29   ADD HL,HL
		binary.cByte(0x01)										# $01 	LD BC,xxxx
		binary.cWord(constant & 0xFFFF)
		binary.cByte(0x09)										# $09   ADD HL,BC
	#
	#		Copy code in (e.g. a macro)
	#
	def copyMacroCode(self,binary,size,addr):
		for i in range(0,size):
			binary.cByte(binary.readByte(addr+i))
