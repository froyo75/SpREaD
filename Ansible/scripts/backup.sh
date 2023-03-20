#!/bin/bash
#
#
# Script options (exit script on command fail).
#
set -e
#
DATE=$(date +%Y-%m-%d-%H%M%S)
BACKUP_DIR="/tmp"
SOURCE="/root /home /etc /opt /var/log"
EXCLUDE="--exclude=$BACKUP_DIR/backup-$DATE.tar.gz --exclude=/proc --exclude=/tmp --exclude=/mnt --exclude=/dev --exclude=/sys --exclude=/run --exclude=/media --exclude=/var/log --exclude=/var/cache/apt/archives --exclude=/usr/src/linux-headers* --exclude=/root/lost+found --exclude=/home/lost+found --exclude=/home/*/.gvfs --exclude=/home/*/.cache --exclude=/home/*/.local/share/Trash"
echo "[i] Starting backup job..."
tar -zpcf $BACKUP_DIR/backup-$DATE.tar.gz $EXCLUDE $SOURCE
echo "[DONE]"