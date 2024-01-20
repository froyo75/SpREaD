#!/bin/bash

ENV_FILE=nextcloud.env

if [[ -f ${ENV_FILE} ]]; then
  source ${ENV_FILE}
  export $(sed 's/^#//g' ${ENV_FILE} | cut -d= -f1)
  docker compose up -d
  docker image prune -f
fi