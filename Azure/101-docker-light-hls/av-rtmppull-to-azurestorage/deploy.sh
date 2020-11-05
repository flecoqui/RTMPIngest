# build image you need to run this command in the folder where the dockefile is stored
docker build -t flecoqui/av-rtmppull-to-azurestorage .
# run the container in your local docker
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1935:1935/tcp -d  flecoqui/av-rtmppull-to-azurestorage
# run the container in your local docker  using port 1936 for RTMP
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1936:1936/tcp -e PORT_RTMP=1936 -d  flecoqui/av-rtmppull-to-azurestorage
# debug the container in your local docker
docker run -p 80:80/tcp  -p 8080:8080/tcp   -p 1935:1935/tcp -d -it flecoqui/av-rtmppull-to-azurestorage /bin/bash
# push image 
docker push flecoqui/av-rtmppull-to-azurestorage


 
 