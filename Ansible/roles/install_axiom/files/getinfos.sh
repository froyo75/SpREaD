#!/bin/bash
set -x

OUTPUT_FOLDER=/home/op/info-fleet
mkdir -p ${OUTPUT_FOLDER}

DOMAIN=www.google.com
USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36'
HOST=$(cat /etc/hostname)

echo "Hostname: $HOST" > ${OUTPUT_FOLDER}/${HOST}.log

echo "----- Get IP Infos using 'ip-api.com' -----" >> ${OUTPUT_FOLDER}/${HOST}.log
curl -H "User-Agent: $USER_AGENT" http://ip-api.com/json/ >> ${OUTPUT_FOLDER}/${HOST}.log

echo -e "\n----- Get IP Infos using dig 'o-o.myaddr.l.google.com' -----" >> ${OUTPUT_FOLDER}/${HOST}.log
dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com >> ${OUTPUT_FOLDER}/${HOST}.log

echo "----- Request https://$DOMAIN using curl -----" >> ${OUTPUT_FOLDER}/${HOST}.log
curl -I -v -H "User-Agent: $USER_AGENT" https://$DOMAIN >> ${OUTPUT_FOLDER}/${HOST}.log

echo "----- Request https://$DOMAIN using curl with no check certificate -----" >> ${OUTPUT_FOLDER}/${HOST}.log
curl -I -v -H -k "User-Agent: $USER_AGENT" https://$DOMAIN >> ${OUTPUT_FOLDER}/${HOST}.log

echo "----- Request $DOMAIN using dig -----" >> ${OUTPUT_FOLDER}/${HOST}.log
dig A $DOMAIN >> ${OUTPUT_FOLDER}/${HOST}.log

echo "----- Displays the network configuration -----" >> ${OUTPUT_FOLDER}/${HOST}.log
ip a >> ${OUTPUT_FOLDER}/${HOST}.log

echo "----- DNS Leak Test -----" >> ${OUTPUT_FOLDER}/${HOST}.log
ID=$(shuf -i 1000000-9999999 -n 1)
API_DOMAIN=bash.ws
for i in $(seq 1 10); do
    ping -c 1 "$i.$ID.$API_DOMAIN" > /dev/null 2>&1
done
DNS_LEAK=$(curl --silent "https://$API_DOMAIN/dnsleak/test/$ID?json")
echo $DNS_LEAK >> ${OUTPUT_FOLDER}/${HOST}.log
