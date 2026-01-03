#!/bin/bash

DEFAULT_TERRA_PATH=$(realpath ./Terraform)

checkstatus() {
  step=$1
  retVal=$2

  if [[ $retVal -gt 0 ]]; then
      echo -e "\e[31m[!] Error $step !\e[0m"
  else
      echo -e "\e[32m[+] Done!\e[0m"
  fi
}

createFolder() {
	FOLDERPATH=$1

	if [[ ! -d "${FOLDERPATH}" ]]; then
		echo -e "\e[32m[+] Creating the folder '${FOLDERPATH}'...\e[0m"
		step='creating the folder'
		mkdir -p ${FOLDERPATH}
		checkstatus "$step" $?
	fi
}

setOpName(){
	OP=$1
	FOLDERPATH=$2

	echo -e "\e[32m[+] Setting operation name to '${OP}' for '${FOLDERPATH}'...\e[0m"
	step='setting operation name'
	sed -i -E 's!(op_name[[:space:]]*=[[:space:]]*).*!\1"'"${OP}"'"!g' ${FOLDERPATH}/*.tfvars
	checkstatus "$step" $?
}

setAuthorizedKeysFolder() {
	AUTHORIZED_KEYS_FOLDER=$1
	FOLDERPATH=$2

	echo -e "\e[32m[+] Setting 'authorized_keys' folder for '${FOLDERPATH}'...\e[0m"
	step='setting "authorized_keys" folder'
	sed -i -E 's!(vps_ssh_authorized_keys_folder[[:space:]]*=[[:space:]]*).*!\1"'"${AUTHORIZED_KEYS_FOLDER}"'"!g' ${FOLDERPATH}/*.tfvars
	checkstatus "$step" $?
}

setAdminEmailAddress() {
	ADMIN_EMAIL_ADDRESS=$1
	FOLDERPATH=$2

	echo -e "\e[32m[+] Setting 'admin_email_address' for '${FOLDERPATH}'...\e[0m"
	step='setting "admin_email_address"'
	sed -i -E 's!(vps_admin_email_address[[:space:]]*=[[:space:]]*).*!\1"'"${ADMIN_EMAIL_ADDRESS}"'"!g' ${FOLDERPATH}/*.tfvars
	checkstatus "$step" $?
}

setInfraEnv() {
	DEFAULT_ENV=$1
	FOLDERPATH=$2
	INFRA_ENV=$3

	echo -e "\e[32m[+] Setting global variables for '${FOLDERPATH}'...\e[0m"
	step='setting global variables for the new infrastructure'

	if [[ -n "${INFRA_ENV}" ]]; then
		INFRA_ENV_FILEPATH=$(realpath ${INFRA_ENV})
		if [[ ${INFRA_ENV_FILEPATH} == *.env && -f ${INFRA_ENV_FILEPATH} ]]; then
			cp ${DEFAULT_ENV} ${FOLDERPATH}
			sed -i -e 's!\(ENV_FILENAME=\)\(.*\)!\1'"${INFRA_ENV}"'!g' ${FOLDERPATH}/init-infra.sh
		else
			echo -e "\e[31m[!] Please provide a valid environment variables file ! (example: /home/user/myinfra.env) \e[0m"
			exit 1
		fi
	else 
		ln -s ${DEFAULT_ENV} ${FOLDERPATH}/init-infra.sh
	fi

	checkstatus "$step" $?
}

createSymlinks() {
	PROVIDER=$1
	FOLDERPATH=$2
	AVAILABLE_TF_FILES=$3
	AVAILABLE_TPL_FILES=$4

	echo -e "\e[32m[+] Creating symbolic links to setup the new environment '${FOLDERPATH}'...\e[0m"
	step='creating symbolic links'
	if [[ ${AVAILABLE_TF_FILES[0]} != "none" ]]; then
		for tf_file in "${AVAILABLE_TF_FILES[@]}"
		do
			ln -s ${DEFAULT_TERRA_PATH}/${PROVIDER}/${tf_file} ${FOLDERPATH}/${tf_file}
		done
	fi

	if [[ ${AVAILABLE_TPL_FILES[0]} != "none" ]]; then
		for tpl_file in "${AVAILABLE_TPL_FILES[@]}"
		do
			ln -s ${DEFAULT_TERRA_PATH}/${PROVIDER}/${tpl_file} ${FOLDERPATH}/${tpl_file} 
		done
	fi
	checkstatus "$step" $?
}

genInfra() {
	OP=$1
	ADMIN_EMAIL_ADDRESS=$2
	AUTHORIZED_KEYS_FOLDER=$3
	INFRA_NAME=$4
	PROVIDER=$5
	LIST_OF_SERVICES=$6
	AVAILABLE_SERVICES=$7
	AVAILABLE_TF_FILES=$8
	AVAILABLE_TPL_FILES=$9
	SECURITY_GROUP=${10}
	INFRA_ENV=${11}
	DEFAULT_ENV=${DEFAULT_TERRA_PATH}/${PROVIDER}/init-infra.sh

	echo -e "\e[32m[+] Generating all service templates and folders provided to set up the new infrastructure...\e[0m"
	step='generating all service templates provided to set up the new infrastructure'
	for l_service in "${LIST_OF_SERVICES[@]}"
	do
		found_service=0
		for a_service in "${AVAILABLE_SERVICES[@]}"
		do
			if [ "${a_service}" == "${l_service}" ]; then
				found_service=1
				break
			fi
		done

		if [[ "${found_service}" -eq 1 ]]; then
			FOLDERPATH=${DEFAULT_TERRA_PATH}/${PROVIDER}/${OP}-${INFRA_NAME}-${l_service}
			createFolder ${FOLDERPATH}
			createSymlinks ${PROVIDER} ${FOLDERPATH} ${AVAILABLE_TF_FILES} ${AVAILABLE_TPL_FILES}
			cp ${DEFAULT_TERRA_PATH}/${PROVIDER}/${l_service}.tfvars ${FOLDERPATH}
			setOpName ${OP} ${FOLDERPATH}
			setAdminEmailAddress ${ADMIN_EMAIL_ADDRESS} ${FOLDERPATH}
			setAuthorizedKeysFolder ${AUTHORIZED_KEYS_FOLDER} ${FOLDERPATH}
			setInfraEnv ${DEFAULT_ENV} ${FOLDERPATH} ${INFRA_ENV}			
			if [[ ${SECURITY_GROUP} -eq 1 ]]; then
				if [[ ${l_service} == "brc4" || ${l_service} == "cs" || ${l_service} == "havoc" ]]; then
					l_service=c2server
				fi
				ln -s ${DEFAULT_TERRA_PATH}/${PROVIDER}/secgrp-${l_service}.tf ${FOLDERPATH}/secgrp-${l_service}.tf
			fi
		else
				echo -e "\e[31m[!] Error service not found '${l_service}' !\e[0m"
				echo -e "\e[31m[!] List of services available for the specified provider '${PROVIDER}': $(printf "%s," "${AVAILABLE_SERVICES[@]}"| sed 's/,$//')\e[0m"
		fi
	done
	checkstatus "$step" $?
}

if [[ $# -eq 0 || -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]; then
	echo "Usage: $0 <Operation Name (example:rtX)> <Admin Email Address (example:rtops@example.com)> <Authorized Keys Folder (example:./ssh/rtX)> <Infra Name (example:mycompany)> <Provider Name (aws|digitalocean|azure)> <Service Type 1,Service Type 2,... (example: recon,ax,simple-smtp,simple-cdn,evilginx,evilginx-cdn,evilginx-cdn-adfs,nextcloud,mailu,gophish,gophish-evilginx,c2proxy,c2proxy-cdn,clonesite,brc4,cs,havoc)> [global infra env variables file path (default: ${DEFAULT_TERRA_PATH}/infra.env)]"
else
	OP=$1
	ADMIN_EMAIL_ADDRESS=$2
	AUTHORIZED_KEYS_FOLDER=$3
	INFRA_NAME=${4// /_}
	PROVIDER=$5
	SERVICES=$6
	INFRA_ENV=$7
	SECURITY_GROUP=0
	
	OLD_IFS=$IFS
	IFS=','
	read -ra LIST_OF_SERVICES <<< "${SERVICES}"
	IFS=$OLD_IFS

	case "$PROVIDER" in
	aws)
		AVAILABLE_SERVICES=("recon" "ax" "evilginx" "evilginx-cdn" "nextcloud" "mailu" "gophish" "gophish-evilginx" "c2proxy" "c2proxy-cdn" "clonesite" "brc4" "cs" "havoc")
		AVAILABLE_TF_FILES=("main.tf" "outputs.tf" "provider.tf" "variables.tf")
		AVAILABLE_TPL_FILES=("hosts.tpl" "host_vars.tpl")
		SECURITY_GROUP=1
	;;
	digitalocean)
		AVAILABLE_SERVICES=("recon" "ax" "evilginx" "evilginx-cdn" "nextcloud" "mailu" "gophish" "gophish-evilginx" "c2proxy" "c2proxy-cdn" "clonesite" "brc4" "cs" "havoc")
		AVAILABLE_TF_FILES=("main.tf" "outputs.tf" "provider.tf" "variables.tf")
		AVAILABLE_TPL_FILES=("hosts.tpl" "host_vars.tpl")
	;;
	azure)
		AVAILABLE_SERVICES=("simple-cdn" "evilginx-cdn" "evilginx-cdn-adfs")
		AVAILABLE_TF_FILES=("main.tf" "outputs.tf" "provider.tf" "variables.tf")
		AVAILABLE_TPL_FILES=("none")
	;;
	mailgun)
		AVAILABLE_SERVICES=("simple-smtp")
		AVAILABLE_TF_FILES=("main.tf" "outputs.tf" "provider.tf" "variables.tf")
		AVAILABLE_TPL_FILES=("none")
	;;
	*)
	  echo "Usage: $0 <Operation Name (example:rtX)> <Admin Email Address (example:rtops@example.com)> <Authorized Keys Folder (example:./ssh/rtX)> <Infra Name (example:mycompany)> <Provider Name (aws|digitalocean|azure)> <Service Type 1,Service Type 2,... (example: recon,ax,simple-smtp,simple-cdn,evilginx,evilginx-cdn,evilginx-cdn-adfs,nextcloud,mailu,gophish,gophish-evilginx,c2proxy,c2proxy-cdn,clonesite,brc4,cs,havoc)> [global infra env variables file path (default: ${DEFAULT_TERRA_PATH}/infra.env)]"
	  exit 1
	;;
	esac

	genInfra ${OP} ${ADMIN_EMAIL_ADDRESS} ${AUTHORIZED_KEYS_FOLDER} ${INFRA_NAME} ${PROVIDER} ${LIST_OF_SERVICES} ${AVAILABLE_SERVICES} ${AVAILABLE_TF_FILES} ${AVAILABLE_TPL_FILES} ${SECURITY_GROUP} ${INFRA_ENV}

	echo -e "\e[35m[*] To deploy or destroy your new Terraforma infrastructure, simply run the 'init-infra.sh' bash script located in your new infra folder '${DEFAULT_TERRA_PATH}/${PROVIDER}/${INFRA_NAME}/' and pass a specific variables definitions !\e[0m"
fi
