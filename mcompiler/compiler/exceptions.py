# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		exceptions.py
#		Purpose : 	Compiler Exceptions
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	28th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

class CompilerException(Exception):
	def __init__(self,message):
		Exception.__init__(self)
		self.message = message 

	def getMessage(self):
		return self.message

if __name__ == "__main__":
	raise CompilerException("Compiler test")