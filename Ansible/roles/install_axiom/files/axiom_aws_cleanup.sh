#!/bin/bash

#set -e

AXIOM_PATH="$HOME/.axiom"

if [[ -f "$AXIOM_PATH/axiom.json" ]]; then
    sec_group_id=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=axiom-controller" --query 'SecurityGroups[0].GroupId' --output text)
    ami_name=$(jq -r '.imageid' "$AXIOM_PATH"/axiom.json)
else
    if [[ $# -eq 0 || -z "$1" || -z "$2" ]]; then
        echo "Usage: $0 <AMI ID> <Security Group ID>"
        exit 1
    else
        ami_name=$1
        sec_group_id=$2
    fi
fi
    
echo -e "\e[32m[*]  Cleanup security group and images associated with the Axiom profile..."
aws ec2 delete-security-group --group-id $sec_group_id
aws ec2 describe-images --filters "Name=name,Values=$ami_name" --query 'Images[0].ImageId' --output text | xargs -I {} aws ec2 deregister-image --image-id {}
echo -e "[*] Done.\e[0m"