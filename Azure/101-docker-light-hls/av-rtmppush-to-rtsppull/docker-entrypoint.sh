#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi
echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Live Streaming</title>
    <link href="//vjs.zencdn.net/7.8.2/video-js.min.css" rel="stylesheet">
    <script src="//vjs.zencdn.net/7.8.2/video.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/videojs-contrib-eme@3.7.0/dist/videojs-contrib-eme.min.js"></script>
 </head>
 <body>
<video id="player" class="video-js vjs-default-skin" height="360" width="640" controls preload="none">
    <source src="http://'$HOSTNAME:$PORT_HLS'/hls/stream.m3u8" type="application/x-mpegURL" />
 </video>
 <script>
    var player = videojs("#player");
 </script>
 </body>
 <p>HOSTNAME: '$HOSTNAME'</p>
 <p>PORT_HLS: '$PORT_HLS'</p>
 <p>PORT_HTML: '$PORT_HTML'</p>
 <p>PORT_RTMP: '$PORT_RTMP'</p>
 </html>' > /usr/local/nginx/html/player.html

echo "worker_processes  1;
error_log  /testrtmp/log/nginxerror.log debug;
events {
    worker_connections  1024;
 }
http {
    include       mime.types;
    default_type  application/octet-stream;
    keepalive_timeout  65;
    tcp_nopush on;
    directio 512;
    server {
        sendfile        on;
        listen       "$PORT_HTML";
        server_name  localhost;
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            root /usr/build/nginx-rtmp-module;
        }
        location /control {
            rtmp_control all;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
    server {
        sendfile        off;
        listen "$PORT_HLS";
        location /hls {
            add_header 'Cache-Control' 'no-cache';
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Expose-Headers' 'Content-Length';
            if (\$request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain charset=UTF-8';
                add_header 'Content-Length' 0;
                return 204;
            }
            types {
                application/dash+xml mpd;
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /mnt/;
        }
    }
 }
rtmp {
    server {
        listen "$PORT_RTMP";
        ping 30s;
        notify_method get;
        buflen 5s;
        chunk_size 4000;
        application live {
            live on;
            interleave on;
            hls on;
            hls_path /mnt/hls/;
            hls_fragment 3;
            hls_playlist_length 60;
        }
    }
}" > /usr/local/nginx/conf/nginx.conf
exec /usr/local/nginx/sbin/nginx -g "daemon off;" 
#exec /git/gst-rtsp-server/builddir/examples/test-uri rtmp://127.0.0.1:$PORT_RTMP/live/stream
exec /git/gst-rtsp-server/builddir/examples/test-uri http://127.0.0.1:$PORT_HLS/hls/stream.m3u8

exec "$@"
