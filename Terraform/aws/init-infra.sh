#!/bin/bash

if [[ $# -eq 0 || -z "$1" || -z "$2" ]]; then
	echo "$0 <variable_definitions_file_path> <deploy|destroy>"
  else
	VARS_FILE_PATH=$1
	MODE=$2
	ENV_FILENAME=../../infra.env
	if [ -f ${ENV_FILENAME} ]; then
		source ${ENV_FILENAME} 
		export $(sed 's/^#//g' ${ENV_FILENAME} | cut -d= -f1)
		if [ ${MODE^^} == "DEPLOY" ]; then
			terraform init -var-file=${VARS_FILE_PATH}
			terraform plan -var-file=${VARS_FILE_PATH}
			terraform apply -var-file=${VARS_FILE_PATH}
		else
			terraform destroy -var-file=${VARS_FILE_PATH}
		fi
	else
		echo  "'$(realpath ${ENV_FILENAME})'" file not found !
	fi
fi
