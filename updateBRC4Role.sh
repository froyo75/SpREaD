#!/bin/bash
set -e


TEMP_FOLDER=/tmp/bruteratel

if [[ $# -eq 0 || -z "$1" || -z "$2" ]]; then
    	echo "$0 <New-Release-BRC4.tar.gz> <Role Directory Path (example: roles/install_brc4)>"
else

	NEW_RELEASE_BRC4=$1
	ROLE_DIRPATH=$2

	echo -e "\e[32m[+] Extracting '$NEW_RELEASE_BRC4'to '$TEMP_FOLDER'...\e[0m"
	tar -xzf $NEW_RELEASE_BRC4 -C /tmp
	echo -e "\e[32m[+] Updating BRC4 folder '$ROLE_DIRPATH/files'...\e[0m"
	rsync -av --progress --exclude={'*.txt','*.csv','*.pem','*.pdf','install.sh','ratel.conf','.brauth','brute-ratel-armx64','commander-runme','commander'} $TEMP_FOLDER/ $ROLE_DIRPATH/files/
	echo -e "\e[32m[+] Removing '$TEMP_FOLDER' folder...\e[0m"
	rm -rf $TEMP_FOLDER
	echo -e "\e[32m[+] Done\e[0m"
fi
