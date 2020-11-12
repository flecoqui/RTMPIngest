FROM ubuntu:18.04

ENV HOSTNAME 127.0.0.1
ENV PORT_HLS 8080
ENV PORT_HTML 80
ENV PORT_SSL 443
ENV PORT_RTMP 1935


RUN mkdir /git \
&& mkdir /temp \
&& mkdir /testav \
&& mkdir /testav/log \ 
&& chmod 0777 /testav/log \
&& mkdir /testav/config \
&& mkdir -p /usr/local/nginx \
&& mkdir -p /usr/local/nginx/sbin \ 
&& mkdir -p /usr/local/nginx/conf \ 
&& mkdir -p /usr/local/nginx/logs \  
&& mkdir -p /usr/local/nginx/html 
#&& apt-get -y update   
#&& apt-get -y install libpcre3 libpcre3-dev \
#&& apt-get -y install libssl-dev \
#&& apt-get -y install zlib1g-dev

#RUN export CGO_ENABLED=0
#RUN apk add --no-cache bash

# install gstreamer components
#RUN apt-get -y install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
#     gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc \
#    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
#    gstreamer1.0-qt5 gstreamer1.0-pulseaudio

#RUN apt-get -y update \
#    && apt-get -y install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
#     gstreamer1.0-plugins-bad gstreamer1.0 libgstrtspserver-1.0

RUN apt-get -y update \
 #   && apt-get -y install libgstreamer1.0-0 \
 #   && apt-get -y install gstreamer1.0-plugins-bad \
 #   && apt-get -y install gstreamer1.0-plugins-base \ 
 #   && apt-get -y install gstreamer1.0-plugins-good \
 #   && apt-get -y install gstreamer1.0-plugins-ugly \
 #   && apt-get -y install gstreamer1.0-libav  \
 #   && apt-get -y install gstreamer1.0 \
     && apt-get -y install libgstrtspserver-1.0-0 \
    && apt-get -y install gstreamer0.10-qapt

#      gstreamer1.0-plugins-ugly gstreamer1.0-libav  \
#    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa  gstreamer1.0-pulseaudio

# install gstreamer rtsp server
# RUN apt-get -y install libgstrtspserver-1.0

#RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
#RUN apt-get -y install gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev
#RUN apt-get -y install gstreamer1.0-tools  gstreamer1.0-plugins-base  gstreamer1.0-libav  libgstreamer1.0-dev
#RUN apt-get -y install gstreamer1.0-plugins-base  gstreamer1.0-libav   

#RUN apk add nginx
#RUN apk add gstreamer
WORKDIR /usr/local/nginx



#COPY --from=builder /lib/x86_64-linux-gnu/libcrypt.so.1 /lib 
#COPY --from=builder /lib/x86_64-linux-gnu/libpcre.so.3 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstrtspserver-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstreamer-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstnet-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstbase-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstrtp-1.0.so.0  /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstrtsp-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstsdp-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstapp-1.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0 /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0  /lib
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libffi.so.6  /lib
#COPY --from=builder /lib/x86_64-linux-gnu/libselinux.so.1 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/libresolv.so.2 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/libmount.so.1 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/libblkid.so.1 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib
#COPY --from=builder /lib/x86_64-linux-gnu/libuuid.so.1 /lib

RUN echo '<!DOCTYPE html>\n\
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

RUN echo "worker_processes  1;\n\
error_log  /testav/log/nginxerror.log debug;\n\
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

ENV PATH="/usr/local/nginx/sbin:${PATH}"

WORKDIR /
COPY sample_640x360.mp4 /sample_640x360.mp4

#RUN  mkdir /git/gst-rtsp-server \
#&& mkdir /git/gst-rtsp-server/builddir \
#&& mkdir /git/gst-rtsp-server/builddir/examples/
#COPY --from=builder /git/gst-rtsp-server/builddir/examples/test-uri  /git/gst-rtsp-server/builddir/examples/
#COPY --from=builder /git/gst-rtsp-server/builddir/gst/rtsp-server/*  /git/gst-rtsp-server/builddir/examples/
#COPY --from=builder /git/gst-rtsp-server/builddir/gst/rtsp-server/libgstrtspserver*  /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstrtsp* /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libglib* /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstreamer* /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgobject*  /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgstsdp*  /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgio*  /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgst*  /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/libgmodule*  /lib/x86_64-linux-gnu/

EXPOSE 7001/udp $PORT_RTMP/tcp $PORT_HLS/tcp 8554/tcp 8554/udp

COPY docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]

#CMD ["@"]
#ENTRYPOINT ["/bin/sh"]

#STOPSIGNAL SIGTERM

#CMD ["nginx", "-g", "daemon off;"]
