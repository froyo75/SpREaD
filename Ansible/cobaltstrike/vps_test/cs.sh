#!/bin/bash

WORKING_DIR=$(dirname $(realpath $0))
IP=$(hostname -I | cut -f1 -d ' ')
PASSWORD=XXXXXXXXXXXXXXXXXXXXXXX
C2PROFILE=./custom-gmail.profile
KILLDATE=2023-11-03

cd $WORKING_DIR && ./teamserver.sh $IP $PASSWORD $C2PROFILE $KILLDATE