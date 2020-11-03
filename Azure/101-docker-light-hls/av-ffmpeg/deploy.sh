docker build -t flecoqui/av-ffmpeg .
docker run -d  flecoqui/av-ffmpeg
docker run  -d -it flecoqui/av-ffmpeg /bin/bash
docker push flecoqui/av-ffmpeg