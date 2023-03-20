#!/bin/bash

if [[ $# -eq 0 || -z "$1" ]]; then
    echo "$0 <Terraform Folder>"
    exit 1
else
    TERRA_FOLDER=$1
    find ${TERRA_FOLDER} -type f \( -name "terraform.tfstate" -o -name "terraform.tfstate.backup" \) -exec rm -v {} \;
    find ${TERRA_FOLDER} -type d -name .terraform -exec rm -rvf {} \;
fi
