# ****************************************************************************************
# ****************************************************************************************
#
#		Name:		parser.py
#		Purpose:	M7 Compiler Parser
#		Date:		8th August 2018
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************************
# ****************************************************************************************

from exceptions import *

# ****************************************************************************************
#									   M15 Parser
# ****************************************************************************************

class WordParser(object):
	#
	#	Set up
	#
	def __init__(self,sourceCode,fileName = "<None>"):
		# remove tabs, comments
		self.source = sourceCode
		self.source = [x.strip().replace("\t"," ") for x in self.source]
		self.source = [x if x.find("//") < 0 else x[:x.find("//")] for x in self.source]
		# line number and file name
		self.fileName = fileName
		self.lineNumber = 0
		# pre-process strings.
		for i in range(0,len(self.source)):
			if self.source[i].find('"') >= 0:
				self.source[i] = self.processQuotedStrings(self.source[i])
			self.source[i] = self.source[i].strip()
	#
	#	Process quoted strings so spaces inside are replaced by ~
	#	
	def processQuotedStrings(self,line):
		# even lines are quoted strings now.
		line = (" "+line+" ").split('"')
		if len(line) % 2 == 0:
			raise CompilerException("Bad quoted string, imbalanced quotes")
		for i in range(1,len(line),2):
			line[i] = line[i].replace(" ","~")
		return '"'.join(line)
	#
	#	Get next entry, returns "" if none
	#
	def get(self):
		# end of file
		if self.lineNumber >= len(self.source):
			return ""
		# nothing on this line.
		if self.source[self.lineNumber].strip() == "":
			self.lineNumber += 1
			return self.get()
		# extract one token.
		p = (self.source[self.lineNumber]+" ").find(" ")
		token = self.source[self.lineNumber][:p].strip()
		self.source[self.lineNumber] = self.source[self.lineNumber][p:].strip()
		
		WordParser.FILENAME = self.fileName
		WordParser.LINENUMBER = self.lineNumber + 1
		return token if token[0] != '"' else token.replace("~"," ")

if __name__ == "__main__":
	code = """
	//	This is a comment
	4 5 6 $42 "hello world"
	"this is a " 42 42 5 // comment again
	1 "str ing" 
	"s 1" "s 2"
	""".split("\n")
	print(code)
	parser = WordParser(code)
	p = parser.get()
	while p != "":
		print(p,WordParser.LINENUMBER,WordParser.FILENAME)
		p = parser.get()

		