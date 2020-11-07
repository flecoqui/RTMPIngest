#!/bin/sh
# vim:sw=4:ts=4:et

set -e


#exec /git/gst-rtsp-server/builddir/examples/test-uri rtmp://127.0.0.1:$PORT_RTMP/live/stream
#exec /git/gst-rtsp-server/builddir/examples/test-uri file:///sample_640x360.mp4
exec /git/gst-rtsp-server/builddir/examples/test-uri $INPUT_URI

exec "$@"
