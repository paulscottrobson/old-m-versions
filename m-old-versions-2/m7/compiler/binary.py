# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		binary.py
#		Purpose:	M7 Binary Stores
#		Date:		24th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from msystem import *
from exceptions import *
import sys

# ****************************************************************************************
#									Base Binary Objects
# ****************************************************************************************

class BinaryObject(object):
	#
	#		Set up
	#
	def __init__(self):
		self.memory = [ 0 ] * self.getMemorySize() 						# allocate memory
		libInstance = MSystemLibrary()
		self.echo = sys.stdout											# where writes go.
		binary = libInstance.getBinary()								# get binary and copy in.
		for i in range(0,len(binary)):
			self.memory[MSystemLibrary.LOADADDRESS+i] = binary[i]
		self.highAddress = MSystemLibrary.LOADADDRESS + len(binary) - 1	# highest address accessed
		self.pointer = self.readWord(MSystemLibrary.PROGRAMPOINTER)		# address to compile to
		self.pointer += self.readByte(MSystemLibrary.PROGRAMPAGE)<<16 	# a 24 bit page address
		#print("Pointer: {0:04x}".format(self.pointer))
		base = self.readWord(MSystemLibrary.DICTIONARYBASE)				# reset the internal dictionary
		self.writeWord(MSystemLibrary.DICTIONARYNEXTFREE,base)
		self.writeByte(base,0)
	#
	#		Raw read write functions
	#
	def readRaw(self,addr):
		assert addr >= 0 and addr < len(self.memory)
		return self.memory[addr]
	def writeRaw(self,addr,data):
		assert addr >= 0 and addr < len(self.memory)
		assert data >= 0 and data < 256
		self.memory[addr] = data
	#		
	#		Accessors/Mutators
	#
	def readByte(self,addr):
		return self.readRaw(addr)
	#
	def readWord(self,addr):
		return self.readRaw(addr) + (self.readRaw(addr+1) << 8)
	#
	def writeByte(self,addr,data):
		self.highAddress = max(addr,self.highAddress)
		self.writeRaw(addr,data)
	#
	def writeWord(self,addr,data):
		self.highAddress = max(addr+1,self.highAddress)
		self.writeRaw(addr,data & 0xFF)
		self.writeRaw(addr+1,data >> 8)
	#
	def getPointer(self):
		return self.pointer 
	#
	def cByte(self,data):
		if self.echo is not None:
			c = '.' if (data & 0x7F) < 32 else chr(data & 0x7F)
			self.echo.write("\t{0:02x}:{1:04x}   {2:02x}   {3}\n".format(self.pointer >> 16,self.pointer & 0xFFFF,data,c))
		self.writeByte(self.pointer,data)
		self.pointer += 1
	#
	def cWord(self,data):
		if self.echo is not None:
			self.echo.write("\t{0:02x}:{1:04x}   {2:04x}\n".format(self.pointer >> 16,self.pointer & 0xFFFF,data))
		self.writeWord(self.pointer,data)
		self.pointer += 2	
	#
	#		Update next free
	#
	def updateNextFree(self):
		self.writeWord(MSystemLibrary.PROGRAMPOINTER,self.pointer & 0xFFFF)
		self.writeByte(MSystemLibrary.PROGRAMPAGE,self.pointer >> 16)
	#
	#		Write a dictionary item out.
	#
	def writeDictionary(self,word,pageAddress,isImmediate,isCompileOnly):
		if len(word) > 31:
			raise CompilerException("Word '{0}' is too long".format(word))
		self.pointer = self.readWord(MSystemLibrary.DICTIONARYNEXTFREE)
		self.echo = None
		self.cByte(len(word)+5)											# +0 offset
		self.cWord(pageAddress & 0xFFFF)								# +1,+2 address in 64k
		self.cByte(pageAddress >> 16)									# +3 page number
		w = len(word)													# +4 length (0:4) compile only (6)
		w = (w + 0x80) if isImmediate else w 							#    immediate (7) private (5)
		w = (w + 0x40) if isImmediate else w 
		self.cByte(w)
		for c in word.lower():											# +5 word in 7 bit ASCII lower case
			self.cByte(ord(c))
		self.writeWord(MSystemLibrary.DICTIONARYNEXTFREE,self.pointer)
		self.cByte(0)
		if self.pointer >= self.readWord(MSystemLibrary.DICTIONARYEND):	# have we run out of space.
			raise CompilerException("Dictionary out of memory at {0:04x}".format(self.pointer))
	#
	#		Save memory out
	#
	def save(self,writeName):
		h = open(writeName+"."+self.getFileType(),"wb")
		h.write(bytes(self.getWriteChunk()))
		h.close()
	#
	#		Set main address
	#
	def setMainAddress(self,address):
		self.writeWord(MSystemLibrary.RUNTIMEADDRESS,address)

# ****************************************************************************************
#								Spectrum 48k .SNA format
# ****************************************************************************************

class Spectrum48kSNA(BinaryObject):
	#
	#		Get Memory size
	#
	def getMemorySize(self):
		return 0x10000
	#
	#		Get the chunk of memory for writing
	#
	def getWriteChunk(self):
		self.pointer = 0x4000-27											# 27 byte SNA header
		self.echo = None
		self.cByte(0x3F)
		for i in range(0,9):
			self.cWord(0)
		for i in range(0,4):
			self.cByte(0)
		self.cWord(0x5AFE)													# SP, pop start addr from here
		self.cByte(1)
		self.cByte(7)
		assert self.pointer == 0x4000
		self.writeWord(0x5AFE,MSystemLibrary.LOADADDRESS)					# put start $5B00 at TOS
		return self.memory[0x4000-27:0x10000]								# return the .SNA chunk.
	#
	#		Get the file type
	#
	def getFileType(self):
		return "sna"

if __name__ == '__main__':
	sna = Spectrum48kSNA()
	sna.writeDictionary("demo",0x123456,False,False)
	sna.writeDictionary("demo2",0x10ABCD,True,True)
	sna.save("test")
	