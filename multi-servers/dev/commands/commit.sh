#!/bin/bash

# Checking that folder commands should be exist
# to prevent running this file outside dev folder,
# and if the commands folder found, then changing
# current directory to commands
pwd

#if [ ! -d "commands" ]
#then
#	echo "Unable to find folder commands"
#	read x
#	exit
#fi



echo "Committing $1"

# Check if the given file exist otherwise exit
TEMP_FILE="$1.commit"
REAL_FILE=""

case $1 in
	/*) REAL_FILE=$1;;
	*) REAL_FILE=$PWD/$1;;
esac

if [ ! -f "$REAL_FILE" ]
then
	echo "$REAL_FILE does not exist"
	read x
	exit
fi

cp $REAL_FILE $TEMP_FILE

echo "$(basename $REAL_FILE) -> $TEMP_FILE"
if [ $(basename $REAL_FILE) = "vagrant-dev.rb" ]
then
	echo "Remove headers from vagrant-dev.rb"
	sed -i -e '1,10d' $TEMP_FILE
	sed -i '1s/^/CURRENT_DIR = Dir.pwd\n/' $TEMP_FILE
	sed -i '1s/^/##############################################################################\n/' $TEMP_FILE
	sed -i '1s/^/# Please start coding from line 6, otherwise some lines will be lost\n/' $TEMP_FILE
	sed -i '1s/^/# !!!The first 5 lines are managed by dev commands, do not make any changes to them\n/' $TEMP_FILE
	sed -i '1s/^/##############################################################################\n/' $TEMP_FILE
fi
