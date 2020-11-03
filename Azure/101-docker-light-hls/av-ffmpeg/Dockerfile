FROM ubuntu:18.04

# install git
RUN apt-get -y update \
 && apt-get install -y ffmpeg 

COPY docker-entrypoint.sh /
RUN chmod +755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["ffmpeg", "-version"]
