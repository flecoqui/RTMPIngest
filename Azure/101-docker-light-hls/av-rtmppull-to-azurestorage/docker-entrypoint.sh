#!/bin/sh
# vim:sw=4:ts=4:et

set -e

exec /bin/bash /testav/ffmpegloop.sh $INPUT_URI &
exec /bin/bash /testav/azcliloop.sh  $STORAGE_ACCOUNT $STORAGE_CONTAINER $STORAGE_SASTOKEN 

exec "$@"
