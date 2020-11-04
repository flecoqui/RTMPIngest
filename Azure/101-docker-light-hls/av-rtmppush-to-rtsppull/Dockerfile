FROM ubuntu:18.04


ENV HOSTNAME 127.0.0.1
ENV PORT_HLS 8080
ENV PORT_HTML 80
ENV PORT_SSL 443
ENV PORT_RTMP 1935

# install git
RUN apt-get -y update \
 && apt-get install -y git \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y tar  

# install Azure CLI
RUN mkdir /git 
RUN mkdir /temp
RUN mkdir /testrtmp
RUN mkdir /testrtmp/log
RUN chmod +777 /testrtmp/log
RUN mkdir /testrtmp/config

WORKDIR /git 

# install pre-requisites
RUN apt-get -y install build-essential curl g++
# Download source code
WORKDIR /git
RUN apt-get -y install libpcre3 libpcre3-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install libglib2.0-dev
RUN apt-get -y install libgtk2.0-dev
RUN apt-get -y install autoconf
RUN apt-get -y install pkg-config

RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2.tar.gz
RUN tar -zxvf cmake-3.15.2.tar.gz
WORKDIR /git/cmake-3.15.2
RUN ./bootstrap
RUN make
RUN make install

#RUN apt-get -y install meson
RUN  apt-get -y install python3 python3-pip python3-setuptools \
                       python3-wheel ninja-build
RUN pip3 install meson

#git clone https://github.com/nginx/nginx.git
RUN wget http://nginx.org/download/nginx-1.16.1.tar.gz
RUN tar xvfz nginx-1.16.1.tar.gz
RUN git clone https://github.com/arut/nginx-rtmp-module.git 
WORKDIR /git/nginx-1.16.1
# RUN ./configure --with-http_ssl_module --add-module=/git/nginx-rtmp-module
RUN ./configure --add-module=/git/nginx-rtmp-module
RUN make
RUN make install

WORKDIR /git
# Get the gst-rtsp-server source and build
RUN git clone https://github.com/GStreamer/gst-rtsp-server.git
WORKDIR /git/gst-rtsp-server
# current main branch uses meson build, I did not want to figure that out... so 1.16
# RUN git checkout origin/1.16
# RUN ./autogen.sh --noconfigure && GST_PLUGINS_GOOD_DIR=$(pkg-config --variable=pluginsdir gstreamer-plugins-bad-1.0) ./configure && make
RUN meson builddir
WORKDIR /git/gst-rtsp-server/builddir
RUN meson compile
WORKDIR /


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

ENV PATH="/usr/local/nginx/sbin:${PATH}"

# EXPOSE $PORT_HLS
# EXPOSE $PORT_HTML
# EXPOSE $PORT_SSL
# EXPOSE $PORT_RTMP
EXPOSE 7001/udp $PORT_RTMP/tcp $PORT_HLS/tcp 8554/tcp 8554/udp

#RUN ls /usr/local/nginx/sbin 
#CMD ["/usr/local/nginx/sbin/nginx"]
#CMD ["/bin/bash"]

#RUN mkdir /docker-entrypoint.d
COPY docker-entrypoint.sh /
RUN chmod +755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]


STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
