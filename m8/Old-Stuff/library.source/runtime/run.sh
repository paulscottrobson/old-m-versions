
MPROJECT=runtime_test
MROOTPATH=../..

sh build.sh
echo $MPROJECT

if [ -e $MPROJECT.sna ]
then
	fuse $MPROJECT.sna 2>/dev/null
#	wine $MROOTPATH/bin/cspect.exe -zxnext -brk $MPROJECT.sna
#	sh $MROOTPATH/bin/zrun.sh ./ $MPROJECT.sna
fi
