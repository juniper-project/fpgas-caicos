# Given a bitfile as argument 1, prepare and execute an impact batch file to program the FPGA.

if [ -z "$1" ]; then
	echo "Usage: $0 <bitfile>"
	exit 1
fi

sed -e "s|BITFILENAME|$1|g" cmd_template.bat > cmd.bat

impact -batch cmd.bat
