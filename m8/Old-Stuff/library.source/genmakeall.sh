
#
#	Create script to build everything.
#
ls -d */ | awk '{ print "cd ",$1; print "sh build.sh"; print "cd .."; }' >makeall.sh
