# ***********************************************************************************************
# ***********************************************************************************************
#
#		Name : 		loadbootstrap.py
#		Purpose : 	Load Bootstrap page with text.
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Created : 	22nd October 2018
#
# ***********************************************************************************************
# ***********************************************************************************************

import sys

sources = sys.argv[1:]
paging = 512
eos = 0x5E
#
#		Build 'assembler' hash.
#
opcodes = "0000:nop;0001:ldbc,aaaa;0002:ld(bc),a;0003:incbc;0004:incb;0005:decb;0006:ldb,dd;0007:rlca;0008:exaf,af';0009:addhl,bc;000a:lda,(bc);000b:decbc;000c:incc;000d:decc;000e:ldc,dd;000f:rrca;0010:djnzrr;0011:ldde,aaaa;0012:ld(de),a;0013:incde;0014:incd;0015:decd;0016:ldd,dd;0017:rla;0018:jrrr;0019:addhl,de;001a:lda,(de);001b:decde;001c:ince;001d:dece;001e:lde,dd;001f:rra;0020:jrnz,rr;0021:ldhl,aaaa;0022:ld(aaaa),hl;0023:inchl;0024:inch;0025:dech;0026:ldh,dd;0027:daa;0028:jrz,rr;0029:addhl,hl;002a:ldhl,(aaaa);002b:dechl;002c:incl;002d:decl;002e:ldl,dd;002f:cpl;0030:jrnc,rr;0031:ldsp,aaaa;0032:ld(aaaa),a;0033:incsp;0034:inc(hl);0035:dec(hl);0036:ld(hl),dd;0037:scf;0038:jrc,rr;0039:addhl,sp;003a:lda,(aaaa);003b:decsp;003c:inca;003d:deca;003e:lda,dd;003f:ccf;0040:ldb,b;0041:ldb,c;0042:ldb,d;0043:ldb,e;0044:ldb,h;0045:ldb,l;0046:ldb,(hl);0047:ldb,a;0048:ldc,b;0049:ldc,c;004a:ldc,d;004b:ldc,e;004c:ldc,h;004d:ldc,l;004e:ldc,(hl);004f:ldc,a;0050:ldd,b;0051:ldd,c;0052:ldd,d;0053:ldd,e;0054:ldd,h;0055:ldd,l;0056:ldd,(hl);0057:ldd,a;0058:lde,b;0059:lde,c;005a:lde,d;005b:lde,e;005c:lde,h;005d:lde,l;005e:lde,(hl);005f:lde,a;0060:ldh,b;0061:ldh,c;0062:ldh,d;0063:ldh,e;0064:ldh,h;0065:ldh,l;0066:ldh,(hl);0067:ldh,a;0068:ldl,b;0069:ldl,c;006a:ldl,d;006b:ldl,e;006c:ldl,h;006d:ldl,l;006e:ldl,(hl);006f:ldl,a;0070:ld(hl),b;0071:ld(hl),c;0072:ld(hl),d;0073:ld(hl),e;0074:ld(hl),h;0075:ld(hl),l;0076:halt;0077:ld(hl),a;0078:lda,b;0079:lda,c;007a:lda,d;007b:lda,e;007c:lda,h;007d:lda,l;007e:lda,(hl);007f:lda,a;0080:adda,b;0081:adda,c;0082:adda,d;0083:adda,e;0084:adda,h;0085:adda,l;0086:adda,(hl);0087:adda,a;0088:adca,b;0089:adca,c;008a:adca,d;008b:adca,e;008c:adca,h;008d:adca,l;008e:adca,(hl);008f:adca,a;0090:suba,b;0091:suba,c;0092:suba,d;0093:suba,e;0094:suba,h;0095:suba,l;0096:suba,(hl);0097:suba,a;0098:sbca,b;0099:sbca,c;009a:sbca,d;009b:sbca,e;009c:sbca,h;009d:sbca,l;009e:sbca,(hl);009f:sbca,a;00a0:andb;00a1:andc;00a2:andd;00a3:ande;00a4:andh;00a5:andl;00a6:and(hl);00a7:anda;00a8:xorb;00a9:xorc;00aa:xord;00ab:xore;00ac:xorh;00ad:xorl;00ae:xor(hl);00af:xora;00b0:orb;00b1:orc;00b2:ord;00b3:ore;00b4:orh;00b5:orl;00b6:or(hl);00b7:ora;00b8:cpb;00b9:cpc;00ba:cpd;00bb:cpe;00bc:cph;00be:cp(hl);00bf:cpa;00c0:retnz;00c1:popbc;00c2:jpnz,aaaa;00c3:jpaaaa;00c4:callnz,aaaa;00c5:pushbc;00c6:adda,dd;00c7:rstdd;00c8:retz;00c9:ret;00ca:jpz,aaaa;00cc:callz,aaaa;00cd:callaaaa;00ce:adca,dd;00cf:rst08;00d0:retnc;00d1:popde;00d2:jpnc,aaaa;00d3:out(dd),a;00d4:callnc,aaaa;00d5:pushde;00d6:suba,dd;00d7:rst10;00d8:retc;00d9:exx;00da:jpc,aaaa;00db:ina,(dd);00dc:callc,aaaa;00de:sbca,dd;00df:rst18;00e0:retpo;00e1:pophl;00e2:jppo,aaaa;00e3:ex(sp),hl;00e4:callpo,aaaa;00e5:pushhl;00e6:anddd;00e7:rst20;00e8:retpe;00e9:jp(hl);00ea:jppe,aaaa;00eb:exde,hl;00ec:callpe,aaaa;00ee:xordd;00ef:rst28;00f0:retp;00f1:popaf;00f2:jpp,aaaa;00f3:di;00f4:callp,aaaa;00f5:pushaf;00f6:ordd;00f7:rst30;00f8:retm;00f9:ldsp,hl;00fa:jpm,aaaa;00fb:ei;00fc:callm,aaaa;00fe:cpdd;00ff:rst38;cb00:rlcb;cb01:rlcc;cb02:rlcd;cb03:rlce;cb04:rlch;cb05:rlcl;cb06:rlc(hl);cb08:rrcb;cb09:rrcc;cb0a:rrcd;cb0b:rrce;cb0c:rrch;cb0d:rrcl;cb0e:rrc(hl);cb10:rlb;cb11:rlc;cb12:rld;cb13:rle;cb14:rlh;cb15:rll;cb16:rl(hl);cb18:rrb;cb19:rrc;cb1a:rrd;cb1b:rre;cb1c:rrh;cb1d:rrl;cb1e:rr(hl);cb20:slab;cb21:slac;cb22:slad;cb23:slae;cb24:slah;cb25:slal;cb26:sla(hl);cb27:slaa;cb28:srab;cb29:srac;cb2a:srad;cb2b:srae;cb2c:srah;cb2d:sral;cb2e:sra(hl);cb2f:sraa;cb30:slsb;cb31:slsc;cb32:slsd;cb33:slse;cb34:slsh;cb35:slsl;cb36:sls(hl);cb37:slsa;cb38:srlb;cb39:srlc;cb3a:srld;cb3b:srle;cb3c:srlh;cb3d:srll;cb3e:srl(hl);cb3f:srla;cb40:bit0,b;cb41:bit0,c;cb42:bit0,d;cb43:bit0,e;cb44:bit0,h;cb45:bit0,l;cb46:bit0,(hl);cb47:bit0,a;cb48:bit1,b;cb49:bit1,c;cb4a:bit1,d;cb4b:bit1,e;cb4c:bit1,h;cb4d:bit1,l;cb4e:bit1,(hl);cb4f:bit1,a;cb50:bit2,b;cb51:bit2,c;cb52:bit2,d;cb53:bit2,e;cb54:bit2,h;cb55:bit2,l;cb56:bit2,(hl);cb57:bit2,a;cb58:bit3,b;cb59:bit3,c;cb5a:bit3,d;cb5b:bit3,e;cb5c:bit3,h;cb5d:bit3,l;cb5e:bit3,(hl);cb5f:bit3,a;cb60:bit4,b;cb61:bit4,c;cb62:bit4,d;cb63:bit4,e;cb64:bit4,h;cb65:bit4,l;cb66:bit4,(hl);cb67:bit4,a;cb68:bit5,b;cb69:bit5,c;cb6a:bit5,d;cb6b:bit5,e;cb6c:bit5,h;cb6d:bit5,l;cb6e:bit5,(hl);cb6f:bit5,a;cb70:bit6,b;cb71:bit6,c;cb72:bit6,d;cb73:bit6,e;cb74:bit6,h;cb75:bit6,l;cb76:bit6,(hl);cb77:bit6,a;cb78:bit7,b;cb79:bit7,c;cb7a:bit7,d;cb7b:bit7,e;cb7c:bit7,h;cb7d:bit7,l;cb7e:bit7,(hl);cb7f:bit7,a;cb80:res0,b;cb81:res0,c;cb82:res0,d;cb83:res0,e;cb84:res0,h;cb85:res0,l;cb86:res0,(hl);cb87:res0,a;cb88:res1,b;cb89:res1,c;cb8a:res1,d;cb8b:res1,e;cb8c:res1,h;cb8d:res1,l;cb8e:res1,(hl);cb8f:res1,a;cb90:res2,b;cb91:res2,c;cb92:res2,d;cb93:res2,e;cb94:res2,h;cb95:res2,l;cb96:res2,(hl);cb97:res2,a;cb98:res3,b;cb99:res3,c;cb9a:res3,d;cb9b:res3,e;cb9c:res3,h;cb9d:res3,l;cb9e:res3,(hl);cb9f:res3,a;cba0:res4,b;cba1:res4,c;cba2:res4,d;cba3:res4,e;cba4:res4,h;cba5:res4,l;cba6:res4,(hl);cba7:res4,a;cba8:res5,b;cba9:res5,c;cbaa:res5,d;cbab:res5,e;cbac:res5,h;cbad:res5,l;cbae:res5,(hl);cbaf:res5,a;cbb0:res6,b;cbb1:res6,c;cbb2:res6,d;cbb3:res6,e;cbb4:res6,h;cbb5:res6,l;cbb6:res6,(hl);cbb7:res6,a;cbb8:res7,b;cbb9:res7,c;cbba:res7,d;cbbb:res7,e;cbbc:res7,h;cbbd:res7,l;cbbe:res7,(hl);cbbf:res7,a;cbc0:set0,b;cbc1:set0,c;cbc2:set0,d;cbc3:set0,e;cbc4:set0,h;cbc5:set0,l;cbc6:set0,(hl);cbc7:set0,a;cbc8:set1,b;cbc9:set1,c;cbca:set1,d;cbcb:set1,e;cbcc:set1,h;cbcd:set1,l;cbce:set1,(hl);cbcf:set1,a;cbd0:set2,b;cbd1:set2,c;cbd2:set2,d;cbd3:set2,e;cbd4:set2,h;cbd5:set2,l;cbd6:set2,(hl);cbd7:set2,a;cbd8:set3,b;cbd9:set3,c;cbda:set3,d;cbdb:set3,e;cbdc:set3,h;cbdd:set3,l;cbde:set3,(hl);cbdf:set3,a;cbe0:set4,b;cbe1:set4,c;cbe2:set4,d;cbe3:set4,e;cbe4:set4,h;cbe5:set4,l;cbe6:set4,(hl);cbe7:set4,a;cbe8:set5,b;cbe9:set5,c;cbea:set5,d;cbeb:set5,e;cbec:set5,h;cbed:set5,l;cbee:set5,(hl);cbef:set5,a;cbf0:set6,b;cbf1:set6,c;cbf2:set6,d;cbf3:set6,e;cbf4:set6,h;cbf5:set6,l;cbf6:set6,(hl);cbf7:set6,a;cbf8:set7,b;cbf9:set7,c;cbfa:set7,d;cbfb:set7,e;cbfc:set7,h;cbfd:set7,l;cbfe:set7,(hl);cbff:set7,a;dd09:addix,bc;dd19:addix,de;dd21:ldix,aaaa;dd22:ld(aaaa),ix;dd23:incix;dd24:incixh;dd25:decixh;dd26:ldixh,dd;dd29:addix,ix;dd2a:ldix,(aaaa);dd2b:decix;dd2c:incixl;dd2d:decixl;dd2e:ldixl,dd;dd34:inc(ix+0);dd35:dec(ix+0);dd36:ld(ix+0),dd;dd39:addix,sp;dd44:ldb,ixh;dd45:ldb,ixl;dd46:ldb,(ix+0);dd4c:ldc,ixh;dd4d:ldc,ixl;dd4e:ldc,(ix+0);dd54:ldd,ixh;dd55:ldd,ixl;dd56:ldd,(ix+0);dd5c:lde,ixh;dd5d:lde,ixl;dd5e:lde,(ix+0);dd60:ldixh,b;dd61:ldixh,c;dd62:ldixh,d;dd63:ldixh,e;dd64:ldixh,ixh;dd65:ldixh,ixl;dd66:ldh,(ix+0);dd67:ldixh,a;dd68:ldixl,b;dd69:ldixl,c;dd6a:ldixl,d;dd6b:ldixl,e;dd6c:ldixl,ixh;dd6d:ldixl,ixl;dd6e:ldl,(ix+0);dd6f:ldixl,a;dd70:ld(ix+0),b;dd71:ld(ix+0),c;dd72:ld(ix+0),d;dd73:ld(ix+0),e;dd74:ld(ix+0),h;dd75:ld(ix+0),l;dd77:ld(ix+0),a;dd7c:lda,ixh;dd7d:lda,ixl;dd7e:lda,(ix+0);dd84:adda,ixh;dd85:adda,ixl;dd86:adda,(ix+0);dd8c:adca,ixh;dd8d:adca,ixl;dd8e:adca,(ix+0);dd94:suba,ixh;dd95:suba,ixl;dd96:suba,(ix+0);dd9c:sbca,ixh;dd9d:sbca,ixl;dd9e:sbca,(ix+0);dda4:andixh;dda5:andixl;dda6:and(ix+0);ddac:xorixh;ddad:xorixl;ddae:xor(ix+0);ddb4:orixh;ddb5:orixl;ddb6:or(ix+0);ddbc:cpixh;ddbd:cpixl;ddbe:cp(ix+0);dde1:popix;dde3:ex(sp),ix;dde5:pushix;dde9:jp(ix);ed40:inb,(c);ed41:out(c),b;ed42:sbchl,bc;ed43:ld(aaaa),bc;ed44:neg;ed45:retn;ed46:im0;ed47:ldi,a;ed48:inc,(c);ed49:out(c),c;ed4a:adchl,bc;ed4b:ldbc,(aaaa);ed4d:reti;ed4f:ldr,a;ed50:ind,(c);ed51:out(c),d;ed52:sbchl,de;ed53:ld(aaaa),de;ed56:im1;ed57:lda,i;ed58:ine,(c);ed59:out(c),e;ed5a:adchl,de;ed5b:ldde,(aaaa);ed5e:im2;ed5f:lda,r;ed60:inh,(c);ed61:out(c),h;ed62:sbchl,hl;ed68:inl,(c);ed69:out(c),l;ed6a:adchl,hl;ed70:inf,(c);ed71:out(c),f;ed72:sbchl,sp;ed73:ld(aaaa),sp;ed78:ina,(c);ed79:out(c),a;ed7a:adchl,sp;ed7b:ldsp,(aaaa);eda0:ldi;eda1:cpi;eda2:ini;eda3:oti;eda8:ldd;edaa:ind;edab:otd;edb0:ldir;edb1:cpir;edb2:inir;edb3:otir;edb8:lddr;edb9:cpdr;edba:indr;edbb:otdr"
assembler = { "break":0xDD01 }
for pair in opcodes.split(";"):
	pair = pair.split(":")
	assembler[pair[1]] = int(pair[0],16)
#
#		Load in the binary
#
h = open("boot.img","rb")
image = [x for x in h.read(-1)]
h.close()
#
#		Work out where things are.
#
sysInfo = image[4] + image[5] * 256
bootPage = image[sysInfo+16-0x8000]
print("System information at  ${0:04x}".format(sysInfo))
print("Bootstrap page is      ${0:02x}".format(bootPage))
bootAddress = 0x4000 + (bootPage - 0x20) * 0x2000
print("Bootstrap address is   ${0:04x}".format(bootAddress))
while len(image) < bootAddress + 0x4000:
	image.append(0)
executeMode = True
#
#		Erase the bootstrap page
#
for i in range(0,0x4000):
	image[bootAddress+i] = eos
#
#		Load text in.
#
for file in sources:
	startAddress = bootAddress
	src = [x.replace("\t"," ").replace("\n"," ").lower() for x in open(file).readlines()]
	src = [x if x.find("//") < 0 else x[:x.find("//")] for x in src]
	for word in " ".join(src).split(" "):
		if word != "":
#			print(word)
			if word[0] == '{' and word[-1] == '}':
				#print(">>> ",word)
				word = word[1:-1].lower().replace("_","")
				if word not in assembler:
					raise Exception("Unknown assembler "+word)
				word = str(assembler[word])
				#print("<<< ",word)
			if word == "{{" or word == "}}":
				executeMode = (word == "{{")
				word = ""
			assert word != ":",": on its own forbidden"
			if word != "":
				colour = 0xC0 if executeMode else 0x80
				if word[0] == ':':
					word = word[1:]
					colour = 0x00
				required = len(word)+2
				if int(bootAddress/paging) != int((bootAddress+required)/paging):
					while bootAddress % paging != 0:
						image[bootAddress] = eos
						bootAddress += 1
				for c in word+" ":
					image[bootAddress] = (ord(c.upper()) & 0x3F)+colour
					bootAddress += 1
	print("\tFile {0:16} ${1:04x}-${2:04x}".format('"'+file+'"',startAddress,bootAddress))
#
#		Add ending '\0' and save.
#
print("Bootstrap ends at      ${0:04x}".format(bootAddress))
image[bootAddress] = eos
h = open("boot.img","wb")
h.write(bytes(image))
h.close()
