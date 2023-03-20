#!/bin/bash

ENV_FILE=gophish.env

if [[ -f ${ENV_FILE} ]]; then
	source ${ENV_FILE}
	export $(sed 's/^#//g' ${ENV_FILE} | cut -d= -f1)
	if [[ -f ${REDIRECT_RULES} ]]; then
		sed -i 's/TRACK_PARAMETER/'"${TRACK_PARAMETER}"'/g' ${REDIRECT_RULES}
		sed -i 's/RECIPIENT_PARAMETER/'"${RECIPIENT_PARAMETER}"'/g' ${REDIRECT_RULES}
	fi
	docker-compose up -d
	docker image prune -f
fi
