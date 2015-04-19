#!/bin/bash
set -e

APPLICATION=examplejava
MAINCLASS=MainPackage.Main
EXENAME=Main

#JAMAICABASE=/home/iang/jamaica/current/target/linux-x86_64
#TARGET=linux-x86_64
JAMAICABASE=/home/iang/jamaica/current32/target/linux-x86
TARGET=linux-x86
GCCARCH=-m32

PRELOAD=/home/iang/malloc_preload/malloc_preload.so









export PATH=$JAMAICABASE/../../bin/:$PATH

APP_BASE_DIR=`pwd`/$APPLICATION/
LINK_LIBS="-pthread -lrt -ljamaica_ -lm -ldl"

function compile {
	echo "*** Compiling classes... ***"
	mkdir -p classes
	jamaicac -d classes -g `find . -name  "*.java"`
}

function clean {
	set -x
	rm -rf classes/
	rm -rf *.prof
	rm -rf tmp/
	rm -rf $EXENAME
	set +x
	echo "Cleaned."
}

function build {
	compile
	jamaicavmp -cp classes $MAINCLASS
	jamaicabuilder -cp classes \
		-target=$TARGET \
		-setProtocols=none -setLocales=none \
		-setGraphics=none -setFonts=none \
		-XnoSync=true \
		-setTimeZones=Europe/London \
		-percentageCompiled=100 -inline=0 -useProfile=$EXENAME.prof \
		-closed -XkeepTemporaryFiles=true \
		-XnoRuntimeChecks=true \
		$MAINCLASS
}

cd $APP_BASE_DIR


case "$1" in

	'clean' )
		clean
	;;

	'vm' )
		compile
		echo "*** Running in JamaicaVM ***"
		jamaicavm -cp classes $MAINCLASS
	;;

	'build' )
		build
	;;

	'cleanbuild' )
		clean
		build
	;;

	'exec' )
		export LD_PRELOAD=$PRELOAD
		$APP_BASE_DIR/$EXENAME
	;;

	'buildc' )
		#Compile and rebuild the autogenerated C
		FNAME=$2
		if [ "$2" = "" ];
		then
				FNAME="*.c"
		fi

		pushd $APP_BASE_DIR/tmp/ >> /dev/null
		gcc $GCCARCH -I$JAMAICABASE/include -I/home/iang/fpga_interface -g -DNDEBUG -c $FNAME
		gcc $GCCARCH -g -L$JAMAICABASE/lib -L/home/iang/fpga_interface *.o -ljamaica_fpga_interface $LINK_LIBS -o ../$EXENAME
		popd >> /dev/null
	;;

	* )
		echo "Usage: $0 [clean | vm | build | exec | buildc | cleanbuild ]"
	;;

esac


