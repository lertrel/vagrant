#!/bin/bash

CUR_DIR=$PWD
VM_DIR="/vagrant/.vagrant/machines"
INVENTORY_FILE="inventory.txt"
keyPath=".ssh-keys"
keySuffix="_private_key"
vagrantKeyFile="virtualbox/private_key"
keyMode="600"

# Check if production directory exist otherwise exit
if [ ! -d "$VM_DIR" ]
then
	echo "$DEST_DIR is not a directory"
	exit
fi



# Start generating an inventory 
mkdir -p $keyPath

#declare -a NODES
declare -a VMS

cd $VM_DIR

for i in $(ls -1)
do
	NODE_DIR="$VM_DIR/$i"
	if [ -d "$NODE_DIR" ]
	then
		#NODES[${#NODES[@]}]="$NODE_DIR"
		VMS[${#VMS[@]}]="$i"
	fi
done


cd $CUR_DIR

for line in "${VMS[@]}"
do
	sudo cp $VM_DIR/$line/$vagrantKeyFile $keyPath/${line}${keySuffix}
done

for line in "${VMS[@]}"
do
	sudo chmod $keyMode $keyPath/${line}${keySuffix}
done
