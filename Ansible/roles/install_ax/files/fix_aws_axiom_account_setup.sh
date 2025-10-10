#!/bin/bash

AXIOM_PATH="$HOME/.axiom"
name=ax-controller
provider="$(cat "$AXIOM_PATH/axiom.json" | jq -r '.provider')"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

if [[ "$provider" == "aws" ]]; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -q awscliv2.zip; sudo ./aws/install; rm -rf $HOME/aws && rm $HOME/awscliv2.zip
  awscli=$(which aws)
  access_key="$(jq -r '.aws_access_key' "$AXIOM_PATH"/axiom.json)"
  secret_key="$(jq -r '.aws_secret_access_key' "$AXIOM_PATH"/axiom.json)"
  region="$(jq -r '.region' "$AXIOM_PATH"/axiom.json)"
  $awscli configure set aws_access_key_id "$access_key"
  $awscli configure set aws_secret_access_key "$secret_key"
  $awscli configure set default.region "$region"
  sec_group_id=$($awscli ec2 create-security-group --group-name $name --description "Ax SG" --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$name}]" | jq -r '.GroupId')
  sec_group_rule=$($awscli ec2 authorize-security-group-ingress --group-id "$sec_group_id" --protocol tcp --port 2266 --cidr $public_ipv4/32)
  sec_group_owner_id=$(echo "$sec_group_rule" | jq -r '.SecurityGroupRules[].GroupOwnerId')
  sec_group_id=$(echo "$sec_group_rule" | jq -r '.SecurityGroupRules[].GroupId')
  jq --arg sec_group_owner_id "$sec_group_owner_id" '.group_owner_id = $sec_group_owner_id' $AXIOM_PATH/axiom.json > temp.json && mv temp.json $AXIOM_PATH/axiom.json
  jq --arg sec_group_id "$sec_group_id" '.security_group_id = $sec_group_id' $AXIOM_PATH/axiom.json > temp.json && mv temp.json $AXIOM_PATH/axiom.json
fi