#!/bin/bash

ANSIBLE_FOLDER=Ansible
CURRENT_PWD=$(pwd)
cd $ANSIBLE_FOLDER
for inventory in $(ls -1d *inventory); do
	echo -e "\e[32m[+] Revoking SSH access from '$inventory'...\e[0m"
	ansible-playbook -i $inventory/ revoke-ssh-access.yml
	echo -e "\e[32m[+] Done\e[0m"
done
cd $CURRENT_PWD
