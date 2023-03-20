#!/bin/bash
#
#
# Script options (exit script on command fail).
#
set -e
#
./brute-ratel-linx64 -boomerang -host 0.0.0.0:443 -proxy 0.0.0.0:9050 -sa XXXXXXXXXXXXXXXX -sc cert.pem -sk key.pem -o boomerang.log
