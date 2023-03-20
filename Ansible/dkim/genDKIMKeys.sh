#!/bin/bash

if [[ $# -eq 0 || -z "$1" || -z "$2" ]]; then
    echo "$0 <Domain> <DKIM Key Size (example: 2048)>"
else
    DKIM_DOMAIN=$1
    DKIM_KEY_SIZE=$2
    DKIM_PATH=$DKIM_DOMAIN/$1.dkim.key
    mkdir $DKIM_DOMAIN

    echo -e "\e[32m\n[+] Generating a new '$DKIM_KEY_SIZE' bits DKIM keys in '$DKIM_PATH'...\e[0m"
    openssl genrsa -out $DKIM_PATH $DKIM_KEY_SIZE 2>/dev/null 
    DKIM_PUB_KEY=$(openssl rsa -in $DKIM_PATH -pubout -outform der 2>/dev/null | openssl base64 -A)
    echo -e "\e[32m\n[*] DKIM Public Key => \e[0m $DKIM_PUB_KEY"
    echo -e "\e[32m\n[+] Done.\e[0m"
fi
