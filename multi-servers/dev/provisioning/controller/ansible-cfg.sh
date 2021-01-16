#!/bin/bash

# Constants
ANSIBLE_FILE=ansible-temp.cfg
ANSIBLE_FINAL=ansible-final.cfg
ANSIBLE_BACK=ansible-original.cfg

#Copy to original file to the current location
sudo cp $1 ${ANSIBLE_FILE}

# Edit inventory in ansible.cfg
WORD_REPLACE=inventory
ANSIBLE_SECTION=defaults
ANSIBLE_CONFIG="${WORD_REPLACE} = ${2}"
ANSIBLE_CONFIG="${ANSIBLE_CONFIG//\//\\/}"

sudo sed -i -E "s/^#${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^\[${ANSIBLE_SECTION}\]$/[${ANSIBLE_SECTION}]\n\n${ANSIBLE_CONFIG}/" $ANSIBLE_FILE

# Disable deprecation warnings in ansible.cfg
ANSIBLE_SECTION=defaults
WORD_REPLACE=deprecation_warnings
ANSIBLE_CONFIG="${WORD_REPLACE} = True"
ANSIBLE_CONFIG="${ANSIBLE_CONFIG//\//\\/}"

sudo sed -i -E "s/^#${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^\[${ANSIBLE_SECTION}\]$/[${ANSIBLE_SECTION}]\n\n${ANSIBLE_CONFIG}/" $ANSIBLE_FILE

# Disable host_key_checking in ansible.cfg
ANSIBLE_SECTION=defaults
WORD_REPLACE=host_key_checking
ANSIBLE_CONFIG="${WORD_REPLACE} = False"
ANSIBLE_CONFIG="${ANSIBLE_CONFIG//\//\\/}"

sudo sed -i -E "s/^#${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^\[${ANSIBLE_SECTION}\]$/[${ANSIBLE_SECTION}]\n\n${ANSIBLE_CONFIG}/" $ANSIBLE_FILE

# Setting SSH arguments in ansible.cfg
WORD_REPLACE=ssh_args
ANSIBLE_SECTION=ssh_connection
ANSIBLE_CONFIG="${WORD_REPLACE} = -C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes"
ANSIBLE_CONFIG="${ANSIBLE_CONFIG//\//\\/}"

sudo sed -i -E "s/^#${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^${WORD_REPLACE}\s+=.*$//g" $ANSIBLE_FILE
sudo sed -i -E "s/^\[${ANSIBLE_SECTION}\]$/[${ANSIBLE_SECTION}]\n\n${ANSIBLE_CONFIG}/" $ANSIBLE_FILE

# Removing more than 1 blank lines with just 1 
sudo grep -A1 . $ANSIBLE_FILE | grep -v "^--$" > $ANSIBLE_FINAL

# Back up and replace the original ansible.cfg
sudo cp $1 $ANSIBLE_BACK
sudo cp $ANSIBLE_FILE $1
