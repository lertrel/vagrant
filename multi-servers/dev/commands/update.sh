#!/bin/bash

# Checking that folder commands should be exist
# to prevent running this file outside dev folder,
# and if the commands folder found, then changing
# current directory to commands
pwd

if [ ! -d "commands" ]
then
	echo "Unable to find folder commands"
	read x
	exit
fi

cd commands

echo "Are you sure? [Y/n]"
read x

if [ $x != "Y" ]
then
	echo "Not updating ..."
	read x
	exit
fi



# Path constants
PROD_DIR="../.."
DEV_DIR=".."
#PROD_DIR="../prod"
#DEV_DIR="../dev"
PROVISION_DIR_PROD="${PROD_DIR}/provisioning"



echo "Sync provisioning from production to dev"

# Check if a production directory exist otherwise exit
if [ -d "$PROVISION_DIR_PROD" ]
then
	CMD="cp -r $PROVISION_DIR_PROD $DEV_DIR"
	echo $CMD
	eval $CMD
else
	echo "$PROVISION_DIR_PROD is not a directory"
fi



echo "Sync Vagrantfile from production to dev"

# Check if a Vagrantfile exist otherwise exit
VAGRANTFILE="${PROD_DIR}/Vagrantfile"

if [ ! -f "$VAGRANTFILE" ]
then
	echo "$VAGRANTFILE does not exist"
	read x
	exit
fi

# Copy Vagrantfile and convert it to be vagrant-dev.rb
VAGRANTDEV_TEMP="vagrant-dev.rb.update"
VAGRANTDEV_TEMP2="vagrant-dev.rb.tmp"

# Adding ruby header dev mode, to allow executing
# Vagrantfile (as a mock) via pure ruby (no vagrant)
echo "##############################################################################" > $VAGRANTDEV_TEMP
echo "# !!!The first 10 lines are managed by dev commands, do not make any changes to them" >> $VAGRANTDEV_TEMP
echo "# Please start coding from line 11, otherwise some lines will be lost" >> $VAGRANTDEV_TEMP
echo "##############################################################################" >> $VAGRANTDEV_TEMP
echo "#!/usr/bin/ruby -w" >> $VAGRANTDEV_TEMP
echo "" >> $VAGRANTDEV_TEMP
echo "\$LOAD_PATH << Dir.pwd" >> $VAGRANTDEV_TEMP
echo "\$LOAD_PATH << '/vagrant'" >> $VAGRANTDEV_TEMP
echo "require \"mock-vagrant.rb\"" >> $VAGRANTDEV_TEMP
echo "CURRENT_DIR = '/vagrant'" >> $VAGRANTDEV_TEMP

# Copying content of prodution vagrant file
CMD="cp $VAGRANTFILE $VAGRANTDEV_TEMP2"
echo $CMD
eval $CMD
sed -i -e '1,5d' $VAGRANTDEV_TEMP2

CMD="cat $VAGRANTDEV_TEMP2 >> $VAGRANTDEV_TEMP"
echo $CMD
eval $CMD

# Remove \r from file
sed -i -E "s/\r//g" $VAGRANTDEV_TEMP

VAGRANTDEV="vagrant-dev.rb"

CMD="cp $DEV_DIR/$VAGRANTDEV $DEV_DIR/$VAGRANTDEV_TEMP"
echo $CMD
eval $CMD

CMD="cp $VAGRANTDEV_TEMP $DEV_DIR/$VAGRANTDEV"
echo $CMD
eval $CMD

rm $VAGRANTDEV_TEMP

read x

