FROM ubuntu:18.04 As builder



# install git
RUN apt-get -y update \
 && apt-get install -y git \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y tar  


WORKDIR /git 

# install pre-requisites
RUN apt-get -y install build-essential curl g++
# Download source code
WORKDIR /git
RUN apt-get -y install libpcre3 libpcre3-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install zlib1g-dev
#git clone https://github.com/nginx/nginx.git
RUN wget http://nginx.org/download/nginx-1.16.1.tar.gz
RUN tar xvfz nginx-1.16.1.tar.gz
RUN git clone https://github.com/arut/nginx-rtmp-module.git 
WORKDIR /git/nginx-1.16.1
RUN ./configure --add-module=/git/nginx-rtmp-module
RUN make
RUN make install

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
&& chmod +777 /testav/log \
&& mkdir /testav/config


RUN mkdir -p /usr/local/nginx \
&& mkdir -p /usr/local/nginx/sbin \ 
&& mkdir -p /usr/local/nginx/conf \ 
&& mkdir -p /usr/local/nginx/logs \  
&& mkdir -p /usr/local/nginx/html

WORKDIR /usr/local/nginx

COPY --from=builder /usr/local/nginx/sbin/nginx  ./sbin
COPY --from=builder /usr/local/nginx/conf/koi-win  ./conf
COPY --from=builder /usr/local/nginx/conf/koi-utf  ./conf
COPY --from=builder /usr/local/nginx/conf/win-utf  ./conf
COPY --from=builder /usr/local/nginx/conf/mime.types ./conf
COPY --from=builder /usr/local/nginx/conf/mime.types.default ./conf
COPY --from=builder /usr/local/nginx/conf/fastcgi_params ./conf
COPY --from=builder /usr/local/nginx/conf/fastcgi_params.default ./conf
COPY --from=builder /usr/local/nginx/conf/fastcgi.conf ./conf
COPY --from=builder /usr/local/nginx/conf/fastcgi.conf.default ./conf
COPY --from=builder /usr/local/nginx/conf/uwsgi_params ./conf
COPY --from=builder /usr/local/nginx/conf/uwsgi_params.default ./conf
COPY --from=builder /usr/local/nginx/conf/scgi_params ./conf
COPY --from=builder /usr/local/nginx/conf/scgi_params.default ./conf
COPY --from=builder /usr/local/nginx/conf/nginx.conf ./conf
COPY --from=builder /usr/local/nginx/conf/nginx.conf.default ./conf
COPY --from=builder /usr/local/nginx/html/* ./conf/html/
COPY --from=builder /usr/lib/* /usr/lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/* /usr/lib/x86_64-linux-gnu/


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

COPY docker-entrypoint.sh /
RUN chmod +755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]


STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
