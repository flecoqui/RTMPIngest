# build image you need to run this command in the folder where the dockefile is stored
docker build -t flecoqui/av-rtmppush-to-rtsppull .
# run the container in your local docker
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1935:1935/tcp -p 8554:8554/tcp -p 8554:8554/udp -p 7001:7001/udp -d  flecoqui/av-rtmppush-to-rtsppull
# run the container in your local docker  using port 1936 for RTMP
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1936:1936/tcp -e PORT_RTMP=1936 -d  flecoqui/av-rtmppush-to-rtsppull
# debug the container in your local docker
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1935:1935/tcp -d -it flecoqui/av-rtmppush-to-rtsppull /bin/bash
# push image 
docker push flecoqui/av-rtmppush-to-rtsppull

# ffmpeg command to generate rtmp stream on a laptop with a webcam
ffmpeg.exe -v verbose -f dshow -i video="Integrated Webcam":audio="Microphone (Realtek(R) Audio)"  -video_size 1280x720 -strict -2 -c:a aac -b:a 192k -ar 44100 -r 30 -g 60 -keyint_min 60 -b:v 2000000 -c:v libx264 -preset veryfast  -profile main -level 3.0 -pix_fmt yuv420p -bufsize 1800k -maxrate 400k    -f flv rtmp://localhost:1935/live/stream

# when the container is running and fed with rtmp feed, you can open the following urls:
# App to play the hls stream
http://<hostname>/player.html
# HLS stream url
http://<hostname>:8080/hls/stream.m3u8
 
 