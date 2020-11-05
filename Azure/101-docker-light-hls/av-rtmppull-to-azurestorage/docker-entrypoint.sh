#!/bin/sh
# vim:sw=4:ts=4:et

set -e

#/bin/bash /testav/ffmpegloop.sh $INPUT_URI
#/bin/bash /testav/azcliloop.sh  $STORAGE_ACCOUNT $STORAGE_CONTAINER $STORAGE_SASTOKEN

systemctl enable ffmpegloop.service
systemctl start ffmpegloop.service 
systemctl enable azcliloop.service
systemctl start azcliloop.service 

exec "$@"