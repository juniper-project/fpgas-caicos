#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROJECT=caicosout
HOSTNAME=pegasus
HOSTNAMETEMP=/home/iang/vc707_autogen_pr/reconfig

echo -e "\033[31m===========================================================================\033[0m"
echo -e "\033[31m===========================================================================\033[0m"

if [ -z "$HOSTNAMETEMP" ]; then
	echo "Temp directory is unset."
	exit
else
	if [ -z "$PROJECT" ]; then
		echo "Project name is unset"
		exit
	fi
fi

#Delete and remake the target directory
if [ "clean" = "$1" ]; then
	echo "Cleaning remote directory $HOSTNAMETEMP/$PROJECT..."
	ssh -q $HOSTNAME "rm -rf $HOSTNAMETEMP/$PROJECT"
fi

ssh -q $HOSTNAME "mkdir $HOSTNAMETEMP/$PROJECT"

echo -n "Copying project $PROJECT..."
scp -q -r $DIR/* $HOSTNAME:$HOSTNAMETEMP/$PROJECT/
echo "done."

#Build the thing
ssh -q $HOSTNAME "cd $HOSTNAMETEMP/$PROJECT/; . ~/xilinx14.3.sh; vivado_hls script.tcl"

#Bring back the report
scp -q $HOSTNAME:$HOSTNAMETEMP/$PROJECT/prj/solution1/syn/report/hls_csynth.rpt .
