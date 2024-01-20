#!/bin/bash

ENV_FILE=nextcloud.env

createFolder() {
  FOLDERPATH=$1
  if [[ ! -d "${FOLDERPATH}" ]]; then
    echo -e "\e[32m[+] Creating the folder '${FOLDERPATH}'...\e[0m"
    step='creating the folder'
    mkdir -p ${FOLDERPATH}
    checkstatus "$step" $?
  fi
}

checkstatus() {
  step=$1
  retVal=$2
  if [[ $retVal -gt 0 ]]; then
      echo -e "\e[31mError $step !\e[0m"
      exit 1
  else
    echo -e "\e[32mDone!\e[0m"
  fi
}   

if [[ $# -eq 0 || -z "$1" || -z "$2" ]]
  then
    echo "$0 <backup/restore> <backup file>"
  else
        source ${ENV_FILE}
        export $(sed 's/^#//g' ${ENV_FILE} | cut -d= -f1)
        ACTION=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        BACKUP_FILEPATH=$2
        case $ACTION in
          "backup")
            BACKUP_FOLDER=$(dirname ${BACKUP_FILEPATH})
            createFolder ${BACKUP_FOLDER}
            echo -e "\e[32m[+] Enabling maintenance mode for NextCloud...\e[0m"
            step="enabling maintenance mode for NextCloud"
            docker compose exec --user www-data nextcloud php occ maintenance:mode --on
            checkstatus "$step" $?
            echo -e "\e[32m[+] Backing up nextcloud (${BACKUP_FILEPATH})...\e[0m"
            step="backing up nextcloud"
            docker compose exec mariadb \
              /usr/bin/mysqldump \
              -u root \
              --password=${MYSQL_ROOT_PASSWORD} \
              --single-transaction \
              ${MYSQL_DATABASE} > ${BACKUP_FILEPATH}
            checkstatus "$step" $?
            echo -e "\e[32m[+] Disabling maintenance mode for NextCloud...\e[0m"
            step="disabling maintenance mode for NextCloud"
            docker compose exec --user www-data nextcloud php occ maintenance:mode --off
            checkstatus "$step" $?
            ;;
          "restore")
            echo -e "\e[32m[+] Enabling maintenance mode for NextCloud...\e[0m"
            step="enabling maintenance mode for NextCloud"
            docker compose exec --user www-data nextcloud php occ maintenance:mode --on
            checkstatus "$step" $?
            echo -e "\e[32m[+] Restoring nextcloud (${BACKUP_FILEPATH})...\e[0m"
            step="restoring nextcloud"
            docker compose exec -T mariadb \
              /usr/bin/mysql \
              -u root \
              --password=${MYSQL_ROOT_PASSWORD} \
              ${MYSQL_DATABASE} < ${BACKUP_FILEPATH}
            checkstatus "$step" $?
            echo -e "\e[32m[+] Disabling maintenance mode for NextCloud...\e[0m"
            step="disabling maintenance mode for NextCloud"
            docker compose exec --user www-data nextcloud php occ maintenance:data-fingerprint
            docker compose exec --user www-data nextcloud php occ maintenance:mode --off
            checkstatus "$step" $?
            ;;
          *)
           echo "$0 <backup/restore> <backup file>"
           ;;
      esac
fi