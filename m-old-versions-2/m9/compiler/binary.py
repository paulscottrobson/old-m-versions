# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		binary.py
#		Purpose:	M7 Compiler Memory Models
#		Date:		8th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from m_runtime import *

# ****************************************************************************************
#								Base Memory Model
# ****************************************************************************************

class MemoryBase(object):
	#
	#	Set up memory object
	#
	def __init__(self):
		self.echo = False
		runtime = MRuntime()
		# find address of sys.info
		words = [x for x in runtime.getDictionary() if x[:11] == "system.info"]
		assert len(words) == 1
		self.sysInfo = int(words[0][-4:],16)
		# set up memory with the binary
		self.setupMemory(runtime.getBinary())
		# load the pointers in.
		self.memoryPointers = self.getPointers()
		self.currentPointer = self.getDefaultPointer()
	#
	#	Get the address of sys.info which gives technical info on the RTL.
	#
	def getSystemInformation(self):
		return self.sysInfo
	#
	#	Get current write address
	#
	def getAddress(self):
		return self.memoryPointers[self.currentPointer]
	#	
	#	Memory accessor/mutator.
	#
	def write1(self,byte):
		self.write(self.memoryPointers[self.currentPointer],byte)
		self.memoryPointers[self.currentPointer] = self.increment(self.memoryPointers[self.currentPointer])
	#
	def write2(self,word):
		self.write16(self.memoryPointers[self.currentPointer],word)
		self.memoryPointers[self.currentPointer] = self.increment(self.memoryPointers[self.currentPointer])
		self.memoryPointers[self.currentPointer] = self.increment(self.memoryPointers[self.currentPointer])
	#
	def read(self,address):
		return self.rawRead(address)
	def read16(self,address):
		return self.rawRead(address)+self.rawRead(address+1)*256
	#
	def write(self,address,data):
		if self.echo:
			print("${0:04x} : ${1:02x}".format(address,data))
		self.rawWrite(address,data)
	def write16(self,address,data):
		if self.echo:
			print("${0:04x} : ${1:04x}".format(address,data))
		self.rawWrite(address,data & 0xFF)
		self.rawWrite(address+1,data >> 8)
	#
	#	Set the main address
	#
	def setMain(self,address):
		if self.echo:
			print("{0:04x} {1:04x}".format(self.getSystemInformation()+6,address))
		self.write16(self.getSystemInformation()+6,address)

# ****************************************************************************************
#					SNA based (for a SNAP of standard Sinclair Memory)
# ****************************************************************************************

class SpectrumSNA(MemoryBase):
	#
	#	Load runtime into memory
	#
	def setupMemory(self,runtime):
		self.memory = [ 0x00 ] * 0x10000
		for i in range(0,len(runtime)):
			self.memory[0x5B00+i] = runtime[i]
		self.highAddress = 0x5B00+len(runtime)-1
		self.lastInstrument = None
	#
	#	Get the set of working pointers for different memory types.
	#
	def getPointers(self):
		si = self.getSystemInformation()
		ptr = {}
		ptr["fast"] = self.rawRead(si+2)+self.rawRead(si+3) * 256
		ptr["slow"] = self.rawRead(si+0)+self.rawRead(si+1) * 256
		return ptr
	#
	#	Get the default pointer
	#
	def getDefaultPointer(self):
		return "fast"
	#
	#	Read a byte
	#
	def rawRead(self,addr):
		return self.memory[addr]
	#
	#	Write a byte
	#
	def rawWrite(self,addr,data):
		self.memory[addr] = data
		self.highAddress = max(addr,self.highAddress)
	#
	#	Bump an address - error if end of RAM, or reached start of Fast Memory at $8000
	#
	def increment(self,addr):
		addr = addr + 1
		if addr == 0x10000 or addr == 0x8000:
			raise CompilerException("Out of memory")
		return addr
	#
	#	Check if there is sufficient space with paging
	#
	def checkSpaceNewDefinition(self):
		return True
	#
	#	Switch to next page
	#
	def switchNextPage(self):
		raise CompilerException("No paging in SNA Version")
	#
	#	write out as binary
	#
	def writeBinary(self,stub):
		h = open(stub+".bin","wb")
		h.write(bytes(self.memory[0x5B00:self.highAddress+1]))
		h.close()

if __name__ == "__main__":
	m = SpectrumSNA()
	m.setMain(0xABCD)
	m.writeBinary("test")

