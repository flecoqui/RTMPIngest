FROM ubuntu:18.04

# install git
# RUN apt-get -y update \
#  && apt-get install -y ffmpeg
RUN apt -y update 
RUN add-apt-repository ppa:jonathonf/ffmpeg-4
RUN apt -y install ffmpeg

ENTRYPOINT ["ffmpeg"]
CMD ["-version"]
