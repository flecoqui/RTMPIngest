#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi
echo '<!DOCTYPE html>\n\
<html lang="en">\n\
<head>\n\
    <meta charset="UTF-8">\n\
    <title>Live Streaming</title>\n\
    <link href="//vjs.zencdn.net/7.8.2/video-js.min.css" rel="stylesheet">\n\
    <script src="//vjs.zencdn.net/7.8.2/video.min.js"></script>\n\
    <script src="https://cdn.jsdelivr.net/npm/videojs-contrib-eme@3.7.0/dist/videojs-contrib-eme.min.js"></script>\n\
 </head>\n\
 <body>\n\
<video id="player" class="video-js vjs-default-skin" height="360" width="640" controls preload="none">\n\
    <source src="http://'$HOSTNAME:$PORT_HLS'/hls/stream.m3u8" type="application/x-mpegURL" />\n\
 </video>\n\
 <script>\n\
    var player = videojs("#player");\n\
 </script>\n\
 </body>\n\
 <p>HOSTNAME: '$HOSTNAME'</p>\n\
 <p>PORT_HLS: '$PORT_HLS'</p>\n\
 <p>PORT_HTML: '$PORT_HTML'</p>\n\
 <p>PORT_RTMP: '$PORT_RTMP'</p>\n\
 </html>\n' > /usr/local/nginx/html/player.html

echo "worker_processes  1;\n\
error_log  /testrtmp/log/nginxerror.log debug;\n\
events {\n\
    worker_connections  1024;\n\
 }\n\
http {\n\
    include       mime.types;\n\
    default_type  application/octet-stream;\n\
    keepalive_timeout  65;\n\
    tcp_nopush on;\n\
    directio 512;\n\
    server {\n\
        sendfile        on;\n\
        listen       "$PORT_HTML";\n\
        server_name  localhost;\n\
        location /stat {\n\
            rtmp_stat all;\n\
            rtmp_stat_stylesheet stat.xsl;\n\
        }\n\
        location /stat.xsl {\n\
            root /usr/build/nginx-rtmp-module;\n\
        }\n\
        location /control {\n\
            rtmp_control all;\n\
        }\n\
        error_page   500 502 503 504  /50x.html;\n\
        location = /50x.html {\n\
            root   html;\n\
        }\n\
    }\n\
    server {\n\
        sendfile        off;\n\
        listen "$PORT_HLS";\n\
        location /hls {\n\
            add_header 'Cache-Control' 'no-cache';\n\
            add_header 'Access-Control-Allow-Origin' '*' always;\n\
            add_header 'Access-Control-Expose-Headers' 'Content-Length';\n\
            if (\$request_method = 'OPTIONS') {\n\
                add_header 'Access-Control-Allow-Origin' '*';\n\
                add_header 'Access-Control-Max-Age' 1728000;\n\
                add_header 'Content-Type' 'text/plain charset=UTF-8';\n\
                add_header 'Content-Length' 0;\n\
                return 204;\n\
            }\n\
            types {\n\
                application/dash+xml mpd;\n\
                application/vnd.apple.mpegurl m3u8;\n\
                video/mp2t ts;\n\
            }\n\
            root /mnt/;\n\
        }\n\
    }\n\
 }\n\
rtmp {\n\
    server {\n\
        listen "$PORT_RTMP";\n\
        ping 30s;\n\
        notify_method get;\n\
        buflen 5s;\n\
        chunk_size 4000;\n\
        application live {\n\
            live on;\n\
            interleave on;\n\
            hls on;\n\
            hls_path /mnt/hls/;\n\
            hls_fragment 3;\n\
            hls_playlist_length 60;\n\
        }\n\
    }\n\
}\n" > /usr/local/nginx/conf/nginx.conf


exec "$@"
