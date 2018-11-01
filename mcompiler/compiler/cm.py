# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		cm.py
#		Purpose : 	M Compiler
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	29th September 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import os,sys
from exceptions import *
from codegenerator import *
from kernel import *
from linecompiler import *

# ***********************************************************************************************
#										Compiler Class
# ***********************************************************************************************

class Compiler(object):
	def __init__(self,kernel):
		self.kernel = kernel 
		self.lineCompiler = LineCompiler(self.kernel,Z80CodeGenerator())
		Compiler.LINENUMBER = 0
	#
	def compileFile(self,sourceFile):
		Compiler.SOURCEFILE = sourceFile
		Compiler.LINENUMBER = 0
		print("\tCompiling "+sourceFile)
		if not os.path.exists(sourceFile):
			print("File {0} not found".format(sourceFile))
			sys.exit(0)
		src = open(sourceFile).readlines()
		for l in range(0,len(src)):
			Compiler.LINENUMBER = l + 1
			try:
				self.lineCompiler.compileLine(src[l])
			except CompilerException as ex:
				msg = ex.getMessage()
				if Compiler.LINENUMBER != 0:
					msg = "{0}:{1} {2}".format(Compiler.SOURCEFILE,Compiler.LINENUMBER,msg)
				print("\t"+msg)
				sys.exit(1)
	#
	def save(self):
		self.kernel.save()

if __name__ == "__main__":		
	kernel = Type0Kernel("clean"+os.sep+"boot.img")
	print("CM Compiler 1.0 (29-09-18)")
	cm = Compiler(kernel)
	for cFile in sys.argv[1:]:
		if cFile[0] == '-':
			print("Option "+cFile+" unknown")
			sys.exit(1)
		else:
			cm.compileFile(cFile)
	cm.save()
	print("Compilation completed.")
	sys.exit(0)
