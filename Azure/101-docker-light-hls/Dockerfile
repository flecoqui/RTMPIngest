FROM ubuntu:18.04

# install git
RUN apt-get -y update \
 && apt-get install -y git \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y tar \
 && apt-get install -y ffmpeg 


# install Azure CLI
RUN mkdir /git 
WORKDIR /git 
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN wget https://aka.ms/downloadazcopy-v10-linux 
#Expand Archive
RUN tar -xvf downloadazcopy-v10-linux
RUN cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

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


RUN mkdir /testrtmp
RUN echo 'while [ : ]\n\
  do\n\
folder=\$(date  +"%F-%X.%S")\n\
mkdir /chunks/\$folder\n\
echo mkdir /chunks/\$folder >> /testrtmp/log/ffmpeg.log \n\
/usr/bin/ffmpeg -f flv -i rtmp://127.0.0.1:1935/test -c copy -flags +global_header -f segment -segment_time 60 -segment_format_options movflags=+faststart -reset_timestamps 1 -strftime 1 "/chunks/\$folder/%Y-%m-%d_%H-%M-%S_chunk.mp4 \n\
sleep 5 \n\
done \n' >> /testrtmp/ffmpegloop.sh

RUN chmod +x   /testrtmp/ffmpegloop.sh
RUN adduser testrtmpuser --disabled-login

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
    <source src="http://127.0.0.1:8080/hls/stream.m3u8" type="application/x-mpegURL" />\n\
 </video>\n\
 <script>\n\
    var player = videojs("#player");\n\
 </script>\n\
 </body>\n\
 </html>\n\' >> /usr/local/nginx/html/player.html

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
        listen       80;\n\
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
        listen 8080;\n\
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
        listen 1935;\n\
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
}\n" >> /usr/local/nginx/conf/nginx.conf

ENV PORT 8080
EXPOSE 8080
ENV PORT 80
EXPOSE 80
ENV PORT 443
EXPOSE 443
ENV PORT 1935
EXPOSE 1935

CMD ["/usr/local/nginx/sbin/nginx"]

