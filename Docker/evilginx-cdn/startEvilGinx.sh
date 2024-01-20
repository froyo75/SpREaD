#!/bin/bash

PUBLIC_IP=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"')
sed -i 's/PUBLIC_IP/'"${PUBLIC_IP}"'/g' ./app/config.json
docker compose up -d
docker image prune -f
