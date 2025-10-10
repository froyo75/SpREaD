#!/bin/bash

#set -e

TOOLS_FOLDER=.
GETINFOS_SCRIPT_FILEPATH=getinfos.sh
LOG_FILEPATH=stats_$(date '+%Y-%m-%d_%H-%M-%S').log

checkValidIP() {
	IP=$1
	if [[ "$IP" =~ ^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$ ]]; then
  		echo true
	else
  		echo false
	fi
}

check_IP_In_CIDR_Range() {
    CHECK=$(${TOOLS_FOLDER}/grepcidr -D $1 $2)
    if [[ $? -eq 0 ]]; then
        echo valid
    fi
}

checkFileExists() {
    FILEPATH=$1
    if [[ -s "${FILEPATH}" ]]; then
        echo $(wc -l < ${FILEPATH})
    else 
        echo 0
    fi
}

createFolder() {
	FOLDERPATH=$1
	if [[ ! -d "${FOLDERPATH}" ]]; then
		echo -e "\e[32m[*]  All results will be stored in '${FOLDERPATH}'...\e[0m"
		mkdir -pv ${FOLDERPATH}
	fi
}

if [[ $# -eq 0 || -z "$1" ]]; then
	echo "Usage: $0 <createfleet|getinfosfleet|deletefleet|recon|gau|gowitness|nuclei>"
else
	ACTION=$1
	case "$ACTION" in
	createfleet)
		if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <NB INSTANCES> <REGION (DO:LON1,FRA1,AMS3;AWS:eu-west-3,eu-central-1,eu-west-2)>"
		else
			FLEET_NAME=$2
			NB_INSTANCES=$3
			REGIONS=$4

			echo -e "\e[32m[+] Spinning up ${NB_INSTANCES} instances with fleet prefix '${FLEET_NAME}'...\e[0m"
			ax fleet ${FLEET_NAME} -i ${NB_INSTANCES} -r ${REGIONS}
			echo -e "\e[32m[+] Done.\e[0m"
		fi
	;;
	getinfosfleet)
		if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <Output Folder>"
        else
            FLEET_NAME=$2
			OUTPUT_FOLDER=$(realpath $3)
			createFolder ${OUTPUT_FOLDER}

			if [[ ! -f "${GETINFOS_SCRIPT_FILEPATH}" ]]; then
				echo -e "\e[31m[!] The required '$GETINFOS_SCRIPT_FILEPATH' file does not exist.\e[0m"
				exit 1
            fi

			ax select ${FLEET_NAME}\*

			echo -e "\e[32m[+] Retrieving information from instances...\e[0m"
			ax scp ${GETINFOS_SCRIPT_FILEPATH} "${FLEET_NAME}*:getinfos.sh"
			ax exec 'chmod +x getinfos.sh && ./getinfos.sh' -q -t
			ax scp "${FLEET_NAME}*:/home/op/info-fleet/*" ${OUTPUT_FOLDER}/infos-fleet-recon/
			echo -e "\e[32m[+] Done.\e[0m"

			for INFOS_FILEPATH in "${OUTPUT_FOLDER}/infos-fleet-recon"/*; do
  				if [ -f "${INFOS_FILEPATH}" ]; then
					FILENAME=$(basename ${INFOS_FILEPATH} | sed 's/-/./g' | sed 's/ip.//g')
					PUBLIC_IP=$(cat ${INFOS_FILEPATH} | grep -E '^{.*' | head -n1 | jq '.query' | head -n1 | tr -d '"')
					COUNTRY_IP=$(cat ${INFOS_FILEPATH} | grep -E '^{.*' | head -n1 | jq '.countryCode' | head -n1 | tr -d '"')
					mv ${INFOS_FILEPATH} ${OUTPUT_FOLDER}/infos-fleet-recon/${COUNTRY_IP}-${PUBLIC_IP}-${FILENAME}
				fi
			done
         fi
	;;
	deletefleet)
	  	if [[ -z "$2" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)>"
		else
			FLEET_NAME=$2
			echo -e "\e[32m[+] Removing instances with fleet prefix '${FLEET_NAME}'...\e[0m"
			ax rm "${FLEET_NAME}\*" -f
			echo -e "\e[32m[+] Done.\e[0m"
		fi
	;;
	recon)
		if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <Output Folder> <List of Domains from a file> [List of CIDR ranges from file] [CIDR_RANGE_ONLY] [NMAP_SV_SCAN]"
		else
			FLEET_NAME=$2
			OUTPUT_FOLDER=$(realpath $3)
			DOMAIN_LIST=$4
			CIDR_LIST=$5
			CIDR_RANGE_ONLY=${6^^}
			NMAP_SCAN=${7^^}

            nb_dom_list=$(checkFileExists ${DOMAIN_LIST})
			if [[ ${nb_dom_list} == 0 ]]; then
				echo -e "\e[31m[!] A list of domains is required.\e[0m"
				exit 1
			fi

			createFolder ${OUTPUT_FOLDER}/logs
            nb_cidr_list=$(checkFileExists ${CIDR_LIST})
			ax select ${FLEET_NAME}\*

			createFolder ${OUTPUT_FOLDER}/subdomains
			echo -e "\e[32m[*] Retrieving all subdomains of all domains from certificates (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${DOMAIN_LIST} -m tlsx-san-cn --anew -o ${OUTPUT_FOLDER}/subdomains/all_doms_tlsx_subs.txt --quiet --rm-logs 1>/dev/null
			nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_doms_tlsx_subs.txt)
			echo "[+] ${nb_subdoms} subdomains identified."  | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}

			echo -e "\e[32m[*] Fetching all subdomains from domains (passive recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${DOMAIN_LIST} -m subfinder --anew -o ${OUTPUT_FOLDER}/subdomains/all_subfinder_subs.txt --quiet --rm-logs 1>/dev/null
			nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_subfinder_subs.txt)
			echo "[+] ${nb_subdoms} subdomains identified."  | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			
            if [[ ${nb_cidr_list} > 0 ]]; then
                echo -e "\e[32m[*] Retrieving all subdomains of all IP addresses from CIDR ranges (active recon using reverse DNS lookups)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
                ax scan ${CIDR_LIST} -m dnsx-ptr --anew -o ${OUTPUT_FOLDER}/subdomains/all_reverse_subs.txt --quiet --rm-logs 1>/dev/null
                nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_reverse_subs.txt)
                echo "[+] ${nb_subdoms} subdomains identified."  | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
                
                echo -e "\e[32m[*] Retrieving all subdomains of all IP addresses from certificates (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
                ax scan ${CIDR_LIST} -m tlsx-san-cn --anew -o ${OUTPUT_FOLDER}/subdomains/all_cidrs_tlsx_subs.txt --quiet --rm-logs 1>/dev/null
                nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_cidrs_tlsx_subs.txt)
                echo "[+] ${nb_subdoms} subdomains identified."  | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
            fi

            echo -e "\e[32m[*] Merging all subdomains to ${OUTPUT_FOLDER}/subdomains/all_subs.txt...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
            ls -1 ${OUTPUT_FOLDER}/subdomains/*_subs.txt | xargs -I {} cat {} | sort -u > ${OUTPUT_FOLDER}/subdomains/all_subs.txt
            nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_subs.txt)
            echo "[+] ${nb_subdoms} subdomains identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}

            echo -e "\e[32m[*] Retrieving all valid subdomains (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
            if [[ ${nb_subdoms} > 0 ]]; then
                ax scan ${OUTPUT_FOLDER}/subdomains/all_subs.txt -m dnsx-a-re --anew -o ${OUTPUT_FOLDER}/subdomains/all_active_subs.txt --quiet --rm-logs 1>/dev/null
            fi
			
			ORIGINAL_IFS=${IFS}
			IFS=$'\n'
			for active_sub_entry in $(cat ${OUTPUT_FOLDER}/subdomains/all_active_subs.txt);do
				dom=$(echo ${active_sub_entry} | awk -F ' ' '{print $1}')
				ip=$(echo ${active_sub_entry} | awk -F ' ' '{print $3}' | tr -d '[]')
				if [[ ${CIDR_RANGE_ONLY} = CIDR_RANGE_ONLY ]]; then
					InCIDRRange=$(check_IP_In_CIDR_Range ${ip} ${CIDR_LIST})
					if [[ ${InCIDRRange} == "valid" ]]; then
						echo "${dom}:${ip}" | ${TOOLS_FOLDER}/anew -q ${OUTPUT_FOLDER}/subdomains/all_active_subs_ips_in_cidr.txt
						continue
					fi
				fi
				echo "${dom}:${ip}" | ${TOOLS_FOLDER}/anew -q ${OUTPUT_FOLDER}/subdomains/all_active_subs_ips.txt
			done
			IFS=${ORIGINAL_IFS}

			if [[ ${CIDR_RANGE_ONLY} = CIDR_RANGE_ONLY ]]; then
				input_subs_ips_file=${OUTPUT_FOLDER}/subdomains/all_active_subs_ips_in_cidr.txt
			else
				input_subs_ips_file=${OUTPUT_FOLDER}/subdomains/all_active_subs_ips.txt
			fi

			nb_subs_ips_list=$(checkFileExists ${input_subs_ips_file})
			if [[ ${nb_subs_ips_list} > 0 ]]; then
				createFolder ${OUTPUT_FOLDER}/ips
				cat ${input_subs_ips_file} | awk -F ':' '{print $1}' | ${TOOLS_FOLDER}/anew -q  ${OUTPUT_FOLDER}/subdomains/all_scans_subs_only.txt
				cat ${input_subs_ips_file} | awk -F ':' '{print $2}' | ${TOOLS_FOLDER}/anew -q ${OUTPUT_FOLDER}/ips/all_scans_ips_only.txt
				nb_ips=$(checkFileExists ${OUTPUT_FOLDER}/ips/all_scans_ips_only.txt)
				nb_subdoms=$(checkFileExists ${OUTPUT_FOLDER}/subdomains/all_scans_subs_only.txt)
				echo "[+] ${nb_subdoms} subdomains identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				echo "[+] ${nb_ips} IP addresses from subdomains identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				if [[ ${nb_cidr_list} > 0 ]]; then
					echo -e "\e[32m[*] Generating IP Addresses from CIDR Ranges...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
					for cidr in $(cat ${CIDR_LIST});do
						${TOOLS_FOLDER}/listips ${cidr} >> ${OUTPUT_FOLDER}/ips/all_ips_cidr.txt
					done
					cat ${OUTPUT_FOLDER}/ips/all_ips_cidr.txt | ${TOOLS_FOLDER}/anew -q ${OUTPUT_FOLDER}/ips/all_scans_ips_only.txt
					echo -e "\e[32m[+] Done.\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				fi
			fi
            
			createFolder ${OUTPUT_FOLDER}/services
			echo -e "\e[32m[*] Enumerating all valid ports for all IP addresses from CIDR ranges (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${OUTPUT_FOLDER}/ips/all_scans_ips_only.txt -m naabu-full --anew -o ${OUTPUT_FOLDER}/services/all_scans_ips_top_ports_full.txt --quiet --rm-logs 1>/dev/null
			nb_services=$(checkFileExists ${OUTPUT_FOLDER}/services/all_scans_ips_top_ports_full.txt)
			echo "[+] ${nb_services} services identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			
			echo -e "\e[32m[*] Enumerating all valid ports for all subdomains (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${OUTPUT_FOLDER}/subdomains/all_scans_subs_only.txt -m naabu-full --anew -o ${OUTPUT_FOLDER}/services/all_scans_subs_top_ports_full.txt --quiet --rm-logs 1>/dev/null
			nb_services=$(checkFileExists ${OUTPUT_FOLDER}/services/all_scans_subs_top_ports_full.txt)
			echo "[+] ${nb_services} services identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}

			echo -e "\e[32m[*] Merging all scan results to ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full.txt...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			cat ${OUTPUT_FOLDER}/services/all_scans_ips_top_ports_full.txt ${OUTPUT_FOLDER}/services/all_scans_subs_top_ports_full.txt | sort -u > ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full.txt
			nb_services=$(checkFileExists ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full.txt)
			echo "[+] ${nb_services} services." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			shuf ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full.txt > ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full_randomized.txt

			createFolder ${OUTPUT_FOLDER}/http
			echo -e "\e[32m[*] Detecting HTTP interfaces (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full_randomized.txt -m httpx --anew -o ${OUTPUT_FOLDER}/http/all_active_http.txt --quiet --rm-logs 1>/dev/null
			nb_http_services=$(checkFileExists ${OUTPUT_FOLDER}/http/all_active_http.txt)
			echo "[+] ${nb_http_services} web services identified." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}

			if [[ ${NMAP_SCAN} = NMAP_SV_SCAN ]]; then
				echo -e "\e[32m[*] Running Nmap TCP scans for all services identified (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				createFolder ${OUTPUT_FOLDER}/services/nmap
				readarray -t all_active_ports < <(cat ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full_randomized.txt | awk -F ':' '{print $2}' | sort -u)
				for active_port in "${all_active_ports[@]}"; do
					all_subs_ips_active_port=$(cat ${OUTPUT_FOLDER}/services/all_scans_subs_ips_top_ports_full_randomized.txt | grep -E ":${active_port}$" | awk -F ':' '{print $1}')
					echo ${all_subs_ips_active_port} | sed 's/ /\n/g' > ${OUTPUT_FOLDER}/services/nmap/${active_port}_IN_PROGRESS
					ax scan ${OUTPUT_FOLDER}/services/nmap/${active_port}_IN_PROGRESS -m nmapx -p${active_port} -sTVC -Pn -T3 --max-rtt-timeout 2 --min-parallelism 5 --max-rate 1000 -oA ${OUTPUT_FOLDER}/services/nmap/SV_TCP_${active_port} --rm-logs 1>/dev/null
					rm ${OUTPUT_FOLDER}/services/nmap/${active_port}_IN_PROGRESS
				done
				echo -e "\e[32m[+] Done.\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}

				cat ${OUTPUT_FOLDER}/ips/all_scans_ips_only.txt ${OUTPUT_FOLDER}/subdomains/all_scans_subs_only.txt | sort -u > ${OUTPUT_FOLDER}/services/all_scans_subs_ips.txt
				echo -e "\e[32m[*] Running Nmap UDP scans for well-known services (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				ax scan ${OUTPUT_FOLDER}/services/all_scans_subs_ips.txt -m nmapx -pU:161,162,123,53,500,137,111,67,68,69 --open -sUVC -Pn -T3 --max-rtt-timeout 2 --min-parallelism 5 --max-rate 1000 -oA ${OUTPUT_FOLDER}/services/nmap/SV_UDP_ALL_SUBS_IPS --rm-logs 1>/dev/null
				echo -e "\e[32m[+] Done.\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
		fi
	;;
	gau)
	  if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <List of active IP OR Domain's URLs from a file> <Output Folder>"
		else
			FLEET_NAME=$2
			DATA_LIST=$3
			OUTPUT_FOLDER=$(realpath $4)
			createFolder ${OUTPUT_FOLDER}/logs

			ax select ${FLEET_NAME}\*

			createFolder ${OUTPUT_FOLDER}/gau
			echo -e "\e[32m[*] Fetching known URLs of web interfaces (passive recon)......\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${DATA_LIST} -m gau2 --anew -o ${OUTPUT_FOLDER}/gau/all_gau_urls.txt --quiet --rm-logs 1>/dev/null
			nb_urls=$(checkFileExists ${OUTPUT_FOLDER}/gau/all_gau_urls.txt)
			echo "[+] ${nb_urls} known URLs retrieved." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
		fi
	;;
	gowitness)
	  if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <List of active IP OR Domain's URLs from a file> <Output Folder>"
		else
			FLEET_NAME=$2
			DATA_LIST=$3
			OUTPUT_FOLDER=$(realpath $4)
			createFolder ${OUTPUT_FOLDER}/logs

			ax select ${FLEET_NAME}\*

			createFolder ${OUTPUT_FOLDER}/gowitness/screenshots
			echo -e "\e[32m[*] Generating screenshots of web interfaces (active recon)...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			ax scan ${DATA_LIST} -m gowitness -o ${OUTPUT_FOLDER}/gowitness/screenshots --quiet --rm-logs 1>/dev/null
			nb_screenshots=$(ls -1 ${OUTPUT_FOLDER}/gowitness/screenshots | grep -v ".sqlite3" | wc -l)
			echo "[+] ${nb_screenshots} screenshots taken." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
		fi
	;;
	nuclei)
	  if [[ -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
			echo "Usage: $0 $ACTION <FLEET NAME (Only valid characters are allowed: a-z, A-Z, 0-9, . and -)> <List of active IP OR Domain's URLs from a file> <light|intrusive> <Output Folder>"
		else
			FLEET_NAME=$2
			DATA_LIST=$3
			SCAN_MODE=$4
			OUTPUT_FOLDER=$(realpath $5)
			createFolder ${OUTPUT_FOLDER}/logs

			ax select ${FLEET_NAME}\*

			case "$SCAN_MODE" in
			light)
				createFolder ${OUTPUT_FOLDER}/nuclei
				echo -e "\e[32m[+] Performing light recon (fingerprinting etc.) on active URLs using 'nuclei' tool...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				#ax scan ${DATA_LIST} -m nuclei -o ${OUTPUT_FOLDER}/nuclei/non_intrusive_nuclei.txt --quiet --rm-logs 1>/dev/null
				ax scan ${DATA_LIST} -m nuclei -exclude-templates cnvd/ -exclude-templates default-logins/ -exclude-templates fuzzing/ -exclude-templates vulnerabilities/ -exclude-templates cves/ -etags oob,intrusive,generic -stats -c 50 -rl 300 -nc -o ${OUTPUT_FOLDER}/nuclei/non_intrusive_nuclei.txt --quiet --rm-logs 1>/dev/null
			;;
			intrusive)
				createFolder ${OUTPUT_FOLDER}/nuclei
				echo -e "\e[32m[+] Performing intrusive recon on active URLs using 'nuclei' tool...\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
				ax scan ${DATA_LIST} -m nuclei -exclude-templates fuzzing/ -etags intrusive -stats -c 50 -rl 300 -nc -o ${OUTPUT_FOLDER}/nuclei/intrusive_nuclei.txt --quiet --rm-logs 1>/dev/null
			;;
			*)
			echo "Usage: $0 $ACTION $FLEET_NAME $DATA_LIST <light|intrusive> $OUTPUT_FOLDER"
			exit 1
			;;
			esac

			echo -e "\e[32m[*] Results\e[0m" | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			grep -RE "\[info\]" ${OUTPUT_FOLDER}/nuclei/* | sort -u > ${OUTPUT_FOLDER}/nuclei/info-results.txt
			grep -RE "\[low\]" ${OUTPUT_FOLDER}/nuclei/* | sort -u  > ${OUTPUT_FOLDER}/nuclei/low-results.txt
			grep -RE "\[medium\]" ${OUTPUT_FOLDER}/nuclei/* | sort -u  > ${OUTPUT_FOLDER}/nuclei/medium-results.txt
			grep -RE "\[high\]" ${OUTPUT_FOLDER}/nuclei/* | sort -u > ${OUTPUT_FOLDER}/nuclei/high-results.txt
			grep -RE "\[critical\]" ${OUTPUT_FOLDER}/nuclei/* | sort -u  > ${OUTPUT_FOLDER}/nuclei/critical-results.txt
			info_results=$(checkFileExists ${OUTPUT_FOLDER}/nuclei/info-results.txt)
			low_results=$(checkFileExists ${OUTPUT_FOLDER}/nuclei/low-results.txt)
			medium_results=$(checkFileExists ${OUTPUT_FOLDER}/nuclei/medium-results.txt)
			high_results=$(checkFileExists ${OUTPUT_FOLDER}/nuclei/high-results.txt)
			critical_results=$(checkFileExists ${OUTPUT_FOLDER}/nuclei/critical-results.txt)
			if [[ ${info_results} > 0 ]]; then
				echo "[+] ${info_results} reported as info." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
			if [[ ${low_results} > 0 ]]; then
				echo "[+] ${low_results} reported as low." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
			if [[ ${medium_results} > 0 ]]; then
				echo "[+] ${medium_results} reported as medium." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
			if [[ ${high_results} > 0 ]]; then
				echo "[+] ${high_results} reported as high." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
			if [[ ${critical_results} > 0 ]]; then
				echo "[+] ${critical_results} reported as critical." | tee -a ${OUTPUT_FOLDER}/logs/${ACTION}_${LOG_FILEPATH}
			fi
			
			echo -e "\e[32m[*] Cleaning empty files...\e[0m"
			find ${OUTPUT_FOLDER} -type f -empty -delete
			echo -e "\e[32m[+] Done.\e[0m"
		fi
	;;
	*)
	  echo "Usage: $0 <createfleet|getinfosfleet|deletefleet|recon|gau|gowitness|nuclei>"
	;;
	esac
fi
