rm test.bin testsna.sna m_runtime.py testsna.lst
pushd ../build.base
sh build.sh
popd
python compiler.py
zasm testsna.asm -o testsna.sna

