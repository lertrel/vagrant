#!/bin/bash

# Checking that folder commands should be exist
# to prevent running this file outside dev folder,
# and if the commands folder found, then changing
# current directory to commands
pwd
# Check if a production directory exist otherwise exit
if [ ! -d "commands" ]
then
	echo "commands DEV_DIR is not a directory"
	read x
	exit
fi



# Path constants
FILE_PATH=""
FILE_EXT="commit"
DEST_DIR=".."
VAGRANTFILE="Vagrantfile"
VAGRANTDEV="vagrant-dev.rb"



# Check if production directory exist otherwise exit
if [ ! -d "$DEST_DIR" ]
then
	echo "$DEST_DIR is not a directory"
	read x
	exit
fi



# Start committing files
for i in $(ls -R -1)
do
	if [[ $i =~ [^:]+:$ ]]
	then
		FILE_PATH=${i/\:/}
		DEST_PATH=${FILE_PATH/\./$DEST_DIR}
		echo "Searching directory $FILE_PATH ..."
	else
		if [[ $i =~ ^.+\.${FILE_EXT}$ ]] || [[ $i =~ ^.+\.${FILE_EXT}\*$ ]]
		then

			COMMIT_FILE="$FILE_PATH/$i"

			if [ -f $COMMIT_FILE ]
			then
				if [ $i = "${VAGRANTDEV}.${FILE_EXT}" ]
				then
					DEST_FILE="$DEST_PATH/${VAGRANTFILE}"
				else
					DEST_FILE="$DEST_PATH/${i/\.${FILE_EXT}/}"
				fi

				echo "Commiting: $COMMIT_FILE -> $DEST_FILE"
				CMD="mv $COMMIT_FILE $DEST_FILE"
				eval $CMD
			fi
		fi
	fi
done

read x
