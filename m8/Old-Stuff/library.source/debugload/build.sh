
MPROJECT=dbgload_test
MROOTPATH=../..

rm $MPROJECT.sna
pushd $MROOTPATH/core.build >/dev/null
sh build.sh
popd >/dev/null

if [ -e $MROOTPATH/compiler/msystem.py ]
then
	python $MROOTPATH/compiler/m8c.py $MPROJECT.m8
fi

if [ -e $MPROJECT.sna ]
then
	cp debugloader.m8 $MROOTPATH/compiler/lib
fi
