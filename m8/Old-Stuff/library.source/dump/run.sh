
MPROJECT=dump_test
MROOTPATH=../..

sh build.sh

if [ -e $MPROJECT.sna ]
then
	fuse $MPROJECT.sna 
#	wine $MROOTPATH/bin/cspect.exe -zxnext -brk $MPROJECT.sna
#	sh $MROOTPATH/bin/zrun.sh ./ $MPROJECT.sna
fi
