FROM ubuntu:18.04 As builder
# set DEBIAN_FRONTEND for tzdata installation 
RUN DEBIAN_FRONTEND="noninteractive"

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
WORKDIR /git


WORKDIR /git
# Get the gst-rtsp-server source and build
RUN git clone https://github.com/GStreamer/gst-rtsp-server.git
WORKDIR /git/gst-rtsp-server
RUN git checkout remotes/origin/1.14

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get -y install gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev

RUN ls -l /usr/lib/x86_64-linux-gnu/
RUN meson configure -Doption=examples -Doption=tests  
RUN meson builddir
RUN ninja -C builddir
WORKDIR /git/gst-rtsp-server/builddir
RUN meson compile


FROM ubuntu:18.04 

ENV INPUT_URI rtsp://127.0.0.1/test
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

WORKDIR /
RUN  mkdir /git/gst-rtsp-server \
&& mkdir /git/gst-rtsp-server/builddir \
&& mkdir /git/gst-rtsp-server/builddir/examples/
COPY --from=builder /git/gst-rtsp-server/builddir/examples/test-uri  /git/gst-rtsp-server/builddir/examples/


COPY docker-entrypoint.sh /
RUN chmod +755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]
