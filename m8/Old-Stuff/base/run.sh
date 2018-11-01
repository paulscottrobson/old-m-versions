sh build.sh

if [ -e  core.sna ] 
then
	wine ../bin/CSpect.exe -zxnext -brk -cur core.sna
	#fuse --debugger-command "br 0x5B00" core.sna
	#sh ../bin/zrun.sh ./ core.sna
fi 
