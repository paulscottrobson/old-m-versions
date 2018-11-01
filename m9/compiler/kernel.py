# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		kernel.py
#		Purpose : 	Kernel object
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	21st September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import sys
from exceptions import *
from dictionary import *

# ***********************************************************************************************
#
#											Kernel Base Class
#
# ***********************************************************************************************

class Kernel(object):
	#
	#		Initialise
	#
	def __init__(self,binaryFile):
		# Create dictionary and get basic info
		self.dictionary = Dictionary(binaryFile.replace(".mbin",".mref"))
		self.base = self.dictionary.getBaseAddress()
		self.info = self.dictionary.getSystemInfo()
		# Create physical memory
		self.memory = [ 0x00 ] * self.getMemorySize()
		# Load in kernel binary and copy it into memory
		kernelBinary = [x for x in open(binaryFile,"rb").read(-1)]
		assert len(kernelBinary) + self.base < 0x10000,"Kernel doesn't fit"
		for i in range(0,len(kernelBinary)):
			self.memory[i+self.base] = kernelBinary[i]
		# The highest memory address written
		self.highestMemoryWritten = self.base + len(kernelBinary) - 1
		# Get the free Data and Free Code pointers.
		self.freeData = self._rawReadWord(self.info+2)
		self.freeCode = self._rawReadWord(self.info+4)
		self.freeCode = self.freeCode + self._rawRead(self.info+6) * 0x10000
		#print("{0:04x} {1:06x}".format(self.freeData,self.freeCode))
		self.echo = sys.stdout
	#
	#		Update for writing
	#
	def update(self):
		self._rawWriteWord(self.info+2,self.freeData)
		self._rawWriteWord(self.info+4,self.freeCode & 0xFFFF)
		self._rawWrite(self.info+6,self.freeCode >> 24)	
		mainItem = self.getDictionary().find("main")
		if mainItem is not None:
			self._rawWriteWord(self.info+10,mainItem.getAddress())
	#
	#		Write out.
	#
	def save(self,binaryFile):
		self.update()
		self.dictionary.save(binaryFile.replace(".mbin",".mref"))
		h = open(binaryFile,"wb")
		h.write(bytes(self.memory[self.base:self.map(self.highestMemoryWritten+1)]))
		h.close()
	#
	#		Access dictionary
	#
	def getDictionary(self):
		return self.dictionary
	#
	#		Get code pointer
	#
	def getCodePointer(self):
		return self.freeCode
	#
	#		Raw read/write methods
	#
	def _rawRead(self,address):
		return self.memory[self.map(address)]
	def _rawReadWord(self,address):
		address = self.map(address)
		return self.memory[address] + (self.memory[address+1] << 8)
	def _rawWrite(self,address,data):
		self.highestMemoryWritten = max(self.highestMemoryWritten,address)
		address = self.map(address)
		self.memory[address] = data
		if self.echo is not None:
			c = chr(((data & 0x3F)+0x20)^0x20).lower()
			print("${0:06x} : ${1:02x}\t'{2}'".format(address,data,c))		
	def _rawWriteWord(self,address,data):
		self.highestMemoryWritten = max(self.highestMemoryWritten,address+1)
		address = self.map(address)
		self.memory[self.map(address)] = data & 0xFF
		self.memory[self.map(address)+1] = data >> 8
		if self.echo is not None:
			print("${0:06x} : ${1:04x}".format(address,data))
	#
	#		User methods
	#
	def read(self,address):
		return self._rawRead(address)
	def readWord(self,address):
		return self._rawReadWord(address)
	def write(self,address,data):
		self._rawWrite(address,data)
	def writeWord(self,address,data):
		self._rawWriteWord(address,data)
	#
	#		Compile code
	#
	def cByte(self,data):
		self._rawWrite(self.freeCode,data)
		self.freeCode += 1
	def cWord(self,data):
		self._rawWriteWord(self.freeCode,data)
		self.freeCode += 2

	#
	#		Allocate data memory. Allocate from freedata or freecode if required.
	#
	def allocateData(self,size):
		if self.freeData != 0:
			address = self.freeData
			self.freeData += size
		else:
			address = self.freeCode
			self.freeCode += size
		if self.echo is not None:
			print("${0:06x} : ds ${1:02x}".format(address,size))
		return address
	#
	#		SNA Export 
	#
	def exportSNA(self,snaFile):
		self.update()
		if self.highestMemoryWritten >= 0x10000:
			raise CompilerException("SNA format doesn't support paged loading")
		self.memory[0x4000-27] = 0x3F 					# add .SNA data
		self.memory[0x4000-4] = 0xFE
		self.memory[0x4000-3] = 0x5A
		self.memory[0x4000-2] = 1
		self.memory[0x4000-1] = 7
		self.memory[0x5AFE] = self.base & 0xFF
		self.memory[0x5AFF] = self.base >> 8
		h = open(snaFile,"wb")
		h.write(bytes(self.memory[0x4000-27:0x10000]))
		h.close()

# ***********************************************************************************************
#
#									Standard 48k Spectrum Kernel
#
# ***********************************************************************************************

class Type0Kernel(Kernel):
	def getMemorySize(self):
		return 0x10000
	def map(self,address):
		return 	address
	def nextPage(self,address,memoryRequired = -1):
		raise CompilerException("Paging not supported on Type0 Kernel")

# ***********************************************************************************************
#
#		Kernel has RAM from $5B00-$BFFF, and 4 pages from $C000-$FFFF. These are
#		addresses $05B00-$0BFFF and $xC000-$xFFFF for x = 0..3
#
# ***********************************************************************************************

class Type1Kernel(Kernel):
	#
	#		Amount of actual memory required to represent this.
	#
	def getMemorySize(self):
		return 0xC000 + 4 * 0x4000
	#
	#		Map a 24 bit address to the physical address number
	#
	def map(self,fullAddress):
		if fullAddress < 0xC000:							# Mapping of $00000-$0BFFFF
			return fullAddress 								# (e.g. not paged RAM)
		assert fullAddress < 0x40000 						# Can't be more than this
		assert (fullAddress & 0xFFFF) >= 0xC000 			# must be $C000-$FFFF range
		page = (fullAddress >> 16) 							# Page Number
		return 0xC000 + page * 0x4000 + (fullAddress & 0x3FFF)
	#
	#		Advance a 24 bit pointer to the next page. May be conditional on 
	#		a certain amount of memory being available.
	#
	def nextPage(self,address,memoryRequired = -1):
		if memoryRequired < 0 or ((address & 0xFFFF) + memoryRequired >= 0x10000):
			currentPage = address >> 16
			if currentPage == 3:
				raise CompilerException("Address ${0:06x} cannot go to next page".format(address))
			nextPageAddress = (currentPage + 1) * 0x10000 + 0xC000
			return nextPageAddress
		return address

if __name__ == "__main__":
	k = Type0Kernel("kernel.mbin")
#	for x in [ 0xFFFF,0x1C000,0x1FFFF,0x2C000,0x2FFFF ]:
#		print("${0:06x} -> ${1:06x} -> {2:06x}".format(x,k.map(x),k.nextPage(x)))
#addr = k.allocateData(42)
#addr = k.allocateData(4)
	k.save("test.mbin")
	k.exportSNA("test.sna")
