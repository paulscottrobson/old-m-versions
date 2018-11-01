# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		kernel.py
#		Purpose : 	Kernel object
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	28th September 2018
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
		self.dictionary = Dictionary(binaryFile.replace("boot.img","boot.dict"))
		self.base = self.dictionary.getBaseAddress()
		self.info = self.dictionary.getSystemInfo()
		# Create physical memory
		self.memory = [ 0x00 ] * self.getMemorySize()
		# Load in kernel binary and copy it into memory
		kernelBinary = [x for x in open(binaryFile,"rb").read(-1)]
		assert len(kernelBinary) + self.base < 0x10000,"Kernel doesn't fit"
		loadAddress = self.map(self.base)
		#print(loadAddress,self.base,self.map(self.info))
		for i in range(0,len(kernelBinary)):
			self.memory[i+loadAddress] = kernelBinary[i]
		# The highest memory address written
		self.highestMemoryWritten = self.base + len(kernelBinary) - 1
		# Get the free Data and Free Code pointers.
		self.freeMemory = self.readWord(self.info+0)
		self.freeMemory += (self.read(self.info+1) >> 16)
		#print("{0:04x} {1:06x}".format(self.base,self.freeMemory))
		self.setListing(False)
	#
	#		Update for writing
	#
	def update(self):
		self._rawWriteWord(self.info+0,self.freeMemory & 0xFFFF)
		self._rawWrite(self.info+2,self.freeMemory >> 16)
		mainItem = self.getDictionary().find("main")
		if mainItem is not None:
			self._rawWriteWord(self.info+3,mainItem.getAddress())
	#
	#		Write out.
	#
	def save(self,binaryFile="boot.img"):
		self.update()
		self.dictionary.save(binaryFile.replace("boot.img","boot.dict"))
		h = open(binaryFile,"wb")
		h.write(bytes(self.memory[self.map(self.base):self.map(self.highestMemoryWritten+1)]))
		h.close()
	#
	#		Control listing
	#
	def setListing(self,isOn):
		self.echo = sys.stdout if isOn else None
	#
	#		Access dictionary
	#
	def getDictionary(self):
		return self.dictionary
	#
	#		Get code pointer
	#
	def getCodePointer(self):
		return self.freeMemory
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
		paddress = self.map(address)
		self.memory[paddress] = data
		if self.echo is not None:
			c = chr(((data & 0x3F)^0x20)+0x20).lower()
			print("${0:06x} : ${1:02x}\t'{2}'".format(address,data,c))		
	def _rawWriteWord(self,address,data):
		self.highestMemoryWritten = max(self.highestMemoryWritten,address+1)
		paddress = self.map(address)
		self.memory[paddress] = data & 0xFF
		self.memory[paddress+1] = data >> 8
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
		self._rawWrite(self.freeMemory,data)
		self.freeMemory += 1
	def cWord(self,data):
		self._rawWriteWord(self.freeMemory,data)
		self.freeMemory += 2
	#
	#		Allocate data memory. Allocate from freedata or freecode if required.
	#
	def allocateData(self,size):
		address = self.freeMemory
		self.freeMemory += size
		if self.echo is not None:
			print("${0:06x} : ds ${1:02x}".format(address,size))
		return address

# ***********************************************************************************************
#
#									Standard 48k Spectrum Kernel
#
# ***********************************************************************************************

class Type0Kernel(Kernel):

	def getMemorySize(self):
		return 0x4000 + (32 * 0x4000)

	def map(self,address):
		assert address >= 0x8000
		if address < 0xC000:
			return address-0x8000
		return 0x4000 + (address & 0x3FFF) + (address >> 16) * 0x4000

	def nextPage(self,address,memoryRequired = -1):
		if address < 0xC000:
			return 0xC000
		return (address & 0xFF0000) + 0x01C000

	def getDataWordSize(self):
		return 2

if __name__ == "__main__":
	k = Type0Kernel("clean"+os.sep+"boot.img")
	for x in [ 0xFFFF,0x1C000,0x1FFFF,0x2C000,0x2FFFF ]:
		print("${0:06x} -> ${1:06x} -> {2:06x}".format(x,k.map(x),k.nextPage(x)))
	addr = k.allocateData(42)
	addr = k.allocateData(4)
