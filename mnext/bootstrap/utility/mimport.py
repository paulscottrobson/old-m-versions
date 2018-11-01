# ********************************************************************************************************
# ********************************************************************************************************
#
#		Name : 		mimport.py
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Purpose : 	Import M code into the boot image file.
#		Date : 		22nd September 2018
#
# ********************************************************************************************************
# ********************************************************************************************************

from z80asm import *
import sys

# ********************************************************************************************************
#											Kernel Image Class
# ********************************************************************************************************

class KernelImage(object):
	#
	def __init__(self):
		h = open("boot.img","rb")													# read in the binary
		self.binary = [x for x in h.read(-1)]
		firstPage = self.binary[13]
		self.pointer = (firstPage - 0x20 + 2) * 0x2000
		self.textStart = self.pointer
		self.textEnd = len(self.binary)
		for i in range(self.textStart,self.textEnd):								# fill with spaces.
			self.binary[i] = 0x20
		print("Loading into page ${0:04x}".format(firstPage))		
		h.close()
	#
	def writeImage(self):
		h = open("boot.img","wb")													# write out binary.
		h.write(bytes(self.binary))
		h.close()
	#
	def send(self,byte):
		if False:
			c = ((byte & 0x3F) ^ 0x20) + 0x20
			print("{0:02x} {1}".format(byte,chr(c)))
		self.binary[self.pointer] = byte
		self.pointer += 1
	#
	def align(self,required):
		newPointer = self.pointer + required
		if int(newPointer/1024) != int(self.pointer/1024):
			while self.pointer % 1024 != 0:
				self.send(0x20)
				
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

	def renderText(self,imager,mapper):
		text = self.get().lower().strip()
		if text in mapper:
			text = mapper[text]
		if "&!@".find(text[-1]) >= 0 and text[:-1] in mapper:
			text = mapper[text[:-1]]+text[-1]
		text = text.upper()+" "
		colour = self.getColour()
		imager.align(len(text))
		if text == "variable":
			imager.align(64)
		for c in [ord(x) for x in text]:
			imager.send((c & 0x3F) | colour)

class CommentElement(Element):
	def getColour(self):
		return 0x40
	def getHTMLColour(self):
		return "#FFFFFF"
	def renderText(self,imager,mapper):
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
			return "${0:x}".format(WordElement.LOOKUP[code1])
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
				elif entry[0] == '<' and entry[-1] == '>' and len(entry) > 2:
					self.elements.append(ImmediateElement("{"+entry[1:-1]+"}"))
					self.elements.append(ImmediateElement("a,"))
				elif entry[0] == '[' and entry[-1] == ']' and len(entry) > 2:
					self.elements.append(ImmediateElement(entry[1:-1]))
				else:
					self.elements.append(WordElement(entry))
		if self.commentObject is not None:
			self.elements.append(self.commentObject)

	def renderHTML(self):
		html = "".join([x.renderHTML() for x in self.elements])
		return html+"<br />"

	def renderText(self,imager,mapper):
		for e in self.elements:
			e.renderText(imager,mapper)

# ********************************************************************************************************
#											Source File Class
# ********************************************************************************************************

class SourceFile(object):
	def __init__(self,sourceFile):
		self.sourceFile = sourceFile
		self.mapper = {}

	def importCode(self):
		self.lines = []
		for l in open(self.sourceFile).readlines():
			l = l.strip().lower().replace("\t"," ")
			self.lines.append(Line(l))
		#self.privateShrink()

	def privateShrink(self):
		lastDefinition = None
		lastWasVariable = False
		privateList = []
		for l in self.lines:
			for e in l.elements:
				if isinstance(e,DefineElement):
					lastDefinition = e
				if isinstance(e,WordElement)  and lastWasVariable:
					lastWasVariable = False
					privateList.append(e.get())
				if isinstance(e,WordElement) and e.get() == "variable":
					lastWasVariable = True
				if isinstance(e,WordElement) and e.get() == "private":
					privateList.append(lastDefinition.get())
		privateList = privateList[:26]
		self.mapper = {}
		count = 97
		for k in privateList:
			self.mapper[k] = "_"+chr(count)
			count += 1

	def renderHTML(self,htmlFile):
		h = open(htmlFile,"w")
		h.write("<html><head></head><body style='background-color:black;font-family:sans-serif;font-size:1.5em'>\n")
		for l in self.lines:
			lr = l.renderHTML()
			h.write(lr+"\n")
		h.write("</body></html>\n")
		h.close()

	def renderText(self,imager):
		start = imager.pointer
		for l in self.lines:
			l.renderText(imager,self.mapper)
		pc = int(100*(imager.pointer-imager.textStart) / (imager.textEnd - imager.textStart))
		pc2 = int(100*(imager.pointer-start) / (imager.textEnd - imager.textStart))
		print("\tused ${0:04x} to ${1:04x} {3}% [overall {2}%]".format(start,imager.pointer,pc,pc2))

if __name__ == "__main__":
	kim = KernelImage()
	for w in sys.argv[1:]:
		print("Encoding "+w)
		sf = SourceFile(w)
		sf.importCode()
		sf.renderHTML(w.replace(".m8","_m8")+".html")
		sf.renderText(kim)

	kim.writeImage()

	