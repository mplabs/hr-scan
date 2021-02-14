#!/bin/bash

CONFIG_FILE=/etc/insaned/events/config
DEVICE=${DEVICE-${1}}
if [ -z "$FOLDER" ] ; then
  FOLDER=$(mktemp -d)
fi
PDF_FILE=$(date --iso-8601=seconds).pdf

if [ ! -f $CONFIG_FILE ] ; then
  echo "Config file $CONFIG_FILE does not exist. Run setup.sh to create it." 
  exit 1; 
fi

set -e
source $CONFIG_FILE
set +e

cd $FOLDER
scanadf -d ${DEVICE} -N --resolution ${RESOLUTION} --source "ADF Duplex"
if [ ! -f image-0001 ] ; then 
    exit 0; 
fi
convert image* -adjoin $PDF_FILE
rm image*
if [ -n "{$WEBDAV_URL}" ] ; then
  echo "Uploading $PDF_FILE to $WEBDAV_URL"
  curl -T $PDF_FILE -u $WEBDAV_USER_PASS $WEBDAV_URL
fi