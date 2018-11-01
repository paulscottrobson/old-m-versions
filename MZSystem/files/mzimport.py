# ********************************************************************************************************
# ********************************************************************************************************
#
#		Name : 		mzimport.py
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Purpose : 	Import MZ code into the kernel file.
#		Date : 		2nd October 018
#
# ********************************************************************************************************
# ********************************************************************************************************

from z80asm import *
import sys,re

# ********************************************************************************************************
#											Kernel Image Class
# ********************************************************************************************************

class KernelImage(object):
	#
	def __init__(self,firstPage = 0x22,lastPage = 0x22):

		h = open("boot.img","rb")													# read in the binary
		self.binary = [x for x in h.read(-1)]
		h.close()

		self.textStart = (firstPage-0x20) * 0x2000 + 0x4000							# range of space available.
		self.textEnd = (lastPage-0x20) * 0x2000 + 0x7FFF 						 							
		self.nextFree = self.textStart
		
		print("Source is located from ${0:06x} to ${1:06x}".format(self.textStart,self.textEnd))


		while len(self.binary) < self.textEnd+1:									# pad it out to fit.
			self.binary.append(0x00)

		for i in range(self.textStart,self.textEnd+1):								# Fill it all with spaces.
			self.binary[i] = 0x20
	#
	def writeImage(self,targetFile = "boot.img"):
		h = open(targetFile,"wb")													# write out binary.
		h.write(bytes(self.binary))
		h.close()
	#
	def send(self,byte):
		if False:
			c = ((byte & 0x3F) ^ 0x20) + 0x20
			print("{0:06x} {1:02x} {2}".format(self.nextFree,byte,chr(c)))
		self.binary[self.nextFree] = byte
		self.nextFree += 1
	#
	def requires(self,count):
		nextPointer = self.nextFree + count
		if (nextPointer >> 10) != (self.nextFree >> 10):
			nextPointer = nextPointer >> 10
			self.nextFree = (nextPointer+1) << 10
			

# ********************************************************************************************************
#											Element Classes
# ********************************************************************************************************

class Element(object):
	def __init__(self,text):
		self.text = text.lower().strip()
		#print("<< {1:04x} {0} >>".format(self.text,self.getColour()))

	def get(self):
		return self.text

	def renderHTML(self):
		return "<span style='color:{1};'>{0} </span>".format(self.text,self.getHTMLColour())

	def renderText(self,imager):
		text = self.get().lower().strip()
		if re.match("^\-[0-9]+$",text) is not None:
			text = str(int(text,10) & 0xFFFF)
		text = text.upper()+" "
		imager.requires(len(text)+2)
		colour = self.getColour()
		for c in [ord(x) for x in text]:
			imager.send((c & 0x3F) | colour)

class CommentElement(Element):
	def getColour(self):
		return 0x40
	def getHTMLColour(self):
		return "#FFFFFF"
	def renderText(self,imager):
		pass

class DefineElement(Element):
	def getColour(self):
		return 0x00
	def getHTMLColour(self):
		return "#FF0000"

class WordElement(Element):
	def getColour(self):
		return 0x80
	def getHTMLColour(self):
		return "#00FF00"
	def get(self):
		if self.text[0] == '{' and self.text[-1] == '}':
			return self.assemble(self.text[1:-1])
		return self.text
	def assemble(self,code):
		if WordElement.LOOKUP is None:
			WordElement.LOOKUP = {}
			for e in Z80Opcodes().get().split(";"):
				e = e.split(":")
				WordElement.LOOKUP[e[1]] = int(e[0],16)
		code1 = code.lower().replace("_","").replace(".","")
		if code1 in WordElement.LOOKUP:
			return "{0}".format(WordElement.LOOKUP[code1])
		print("Cannot assemble '{0}'".format(code))
		sys.exit(1)

WordElement.LOOKUP = None

class ImmediateElement(WordElement):
	def getColour(self):
		return 0xC0
	def getHTMLColour(self):
		return "#FFFF00"

# ********************************************************************************************************
#											   Line Class
# ********************************************************************************************************

class Line(object):

	def __init__(self,lineText):
		lineText = lineText.strip().lower()
		self.commentObject = None
		self.elements = []
		if lineText.find("//") >= 0:
			comment = lineText[lineText.find("//")+2:].strip()
			if comment != "":
				self.commentObject = CommentElement(comment)
			lineText = lineText[:lineText.find("//")].strip()
		for entry in lineText.split(" "):
			if entry != "":
				if entry[0] == ':':
					self.elements.append(DefineElement(entry[1:]))
				elif entry == "<<":
					self.elements.append(ImmediateElement("{push.de}"))
					self.elements.append(ImmediateElement("i,"))
					self.elements.append(ImmediateElement("{push.hl}"))
					self.elements.append(ImmediateElement("i,"))
				elif entry == ">>":
					self.elements.append(ImmediateElement("{pop.hl}"))
					self.elements.append(ImmediateElement("i,"))
					self.elements.append(ImmediateElement("{pop.de}"))
					self.elements.append(ImmediateElement("i,"))
				elif entry[0] == '<' and entry[-1] == '>' and len(entry) > 2:
					self.elements.append(ImmediateElement("{"+entry[1:-1]+"}"))
					self.elements.append(ImmediateElement("i,"))
				elif entry[0] == '[' and entry[-1] == ']' and len(entry) > 2:
					self.elements.append(ImmediateElement(entry[1:-1]))
				else:
					self.elements.append(WordElement(entry))
		if self.commentObject is not None:
			self.elements.append(self.commentObject)

	def renderHTML(self):
		html = "".join([x.renderHTML() for x in self.elements])
		return html+"<br />"

	def renderText(self,imager):
		for e in self.elements:
			e.renderText(imager)

# ********************************************************************************************************
#											Source File Class
# ********************************************************************************************************

class SourceFile(object):
	def __init__(self,sourceFile):
		self.sourceFile = sourceFile

	def importCode(self):
		self.lines = []
		for l in open(self.sourceFile).readlines():
			l = l.strip().lower().replace("\t"," ")
			self.lines.append(Line(l))
		self.lines.append(Line("[crunch]"))

	def renderHTML(self,htmlFile):
		h = open(htmlFile,"w")
		h.write("<html><head></head><body style='background-color:black;font-family:sans-serif;font-size:1.5em'>\n")
		for l in self.lines:
			lr = l.renderHTML()
			h.write(lr+"\n")
		h.write("</body></html>\n")
		h.close()

	def renderText(self,imager):
		start = imager.nextFree
		for l in self.lines:
			l.renderText(imager)
		pc = int(100*(imager.nextFree-imager.textStart) / (imager.textEnd - imager.textStart))
		pc2 = int(100*(imager.nextFree-start) / (imager.textEnd - imager.textStart))
		print("\tused ${0:04x} to ${1:04x} {3}% [overall {2}%]".format(start,imager.nextFree,pc,pc2))

if __name__ == "__main__":
	kim = KernelImage()
	for w in sys.argv[1:]:
		print("Encoding "+w)
		sf = SourceFile(w)
		sf.importCode()
		sf.renderHTML(w.replace(".mz","_mz")+".html")
		sf.renderText(kim)
	kim.writeImage()
	