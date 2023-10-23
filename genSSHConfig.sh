#!/bin/bash
set -e

HOST_VARS_FOLDER=host_vars
GROUP_VARS_FOLDER=group_vars

if [[ $# -eq 0 || -z "$1" || -z "$2" ]]; then
    	echo "$0 <Ansible Inventory Folder> <SSH config file> [SOCKS PORT]"
else
        ANSIBLE_INVENTORY_FOLDER=$1
        SSH_CONFIG_FILE=$2
        ANSIBLE_SSH_PRIVATE_KEY_FILE=$(grep ansible_ssh_private_key_file $ANSIBLE_INVENTORY_FOLDER/$GROUP_VARS_FOLDER/all | cut -d: -f2 | tr -d ' ')
        echo -e "\e[32m[*] Generating SSH config file ($SSH_CONFIG_FILE)..."
        for HOST_VARS_FILE in "$ANSIBLE_INVENTORY_FOLDER/$HOST_VARS_FOLDER"/*; do
            SSH_HOST=$(basename $HOST_VARS_FILE)
            ANSIBLE_HOST=$(grep ansible_host $HOST_VARS_FILE | cut -d: -f2 | tr -d ' ')
            ANSIBLE_PORT=$(grep ansible_port $HOST_VARS_FILE | cut -d: -f2 | tr -d ' ')
            ANSIBLE_USER=$(grep ansible_user $HOST_VARS_FILE | cut -d: -f2 | tr -d ' ')
cat <<EOF >> $SSH_CONFIG_FILE
Host $SSH_HOST
   HostName $ANSIBLE_HOST
   User $ANSIBLE_USER
   Port $ANSIBLE_PORT
   IdentityFile $ANSIBLE_SSH_PRIVATE_KEY_FILE
EOF
        if [[ ! -z "$3" ]]; then
            SOCKS_PORT=$3
cat <<EOF >> $SSH_CONFIG_FILE
   DynamicForward $SOCKS_PORT
EOF
        fi
        done
        echo -e "[*] Done.\e[0m"
fi