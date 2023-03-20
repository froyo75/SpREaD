#!/bin/bash

ENV_FILE=mailu.env
CERTS_PATH=/etc/letsencrypt
SECRET_KEY=$(pwgen 16 1)

if [[ -f ${ENV_FILE} ]]; then
    export CERTS_PATH
    sed -i 's/SECRET_KEY=.*/SECRET_KEY='"$SECRET_KEY"'/g' ${ENV_FILE}
    docker-compose up -d
    docker image prune -f
fi
