FROM ubuntu:18.04

# install git
RUN apt-get -y update \
 && apt-get install -y ffmpeg 

ENTRYPOINT ["ffmpeg"]
CMD ["-version"]
