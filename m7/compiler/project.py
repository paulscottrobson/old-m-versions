# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		project.py
#		Purpose:	M7 Project Compiler
#		Date:		27th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from dictionary import *
from exceptions import *
from binary import *
from codegenerator import *
from linecompiler import *
import sys

# ****************************************************************************************
#									Project Compiler
# ****************************************************************************************

class ProjectCompiler(object):
	#
	#	Compile a project
	#
	def __init__(self,initialFile,binary = Spectrum48kSNA()):
		if initialFile[-3:] != ".m7":
			raise CompilerException(initialFile+" is not an m7 file")
		self.binary = binary
		self.dictionary = Dictionary()
		self.codeGenerator = Z80CodeGenerator()
		self.lineCompiler = LineCompiler(self.binary,self.dictionary,self.codeGenerator)
		self.binary.deleteTarget(initialFile[:-3])
		self.importList = []
		try:
			self.compileFile(initialFile)
		except CompilerException as ex:
			error = "{0} {1}:{2}".format(ex.getMessage(),ProjectCompiler.FILENAME,ProjectCompiler.LINENUMBER)
			print(error)
			sys.exit(-1)
		self.binary.save(initialFile[:-3])
	#
	#	Compile a single file
	#
	def compileFile(self,fileName):
		self.importList.append(fileName)
		try:
			source = open(fileName).readlines()
		except FileNotFoundError:
			print("Can't open "+fileName)
			sys.exit(-1)
		for i in range(0,len(source)):
			ProjectCompiler.FILENAME = fileName
			ProjectCompiler.LINENUMBER = i+1
			if len(source[i]) > 6 and source[i][:6] == "import":
				impFile = source[i][6:]
				impFile = impFile if impFile.find("//") < 0 else impFile[:impFile.find("//")]
				impFile = impFile.strip().lower()
				if impFile not in self.importList:
					self.compileFile(impFile)
			else:
				self.lineCompiler.compile(source[i])
		self.dictionary.purgePrivateDictionaryEntries()

if __name__ == '__main__':
	ProjectCompiler("test.m7")
	sys.exit(0)