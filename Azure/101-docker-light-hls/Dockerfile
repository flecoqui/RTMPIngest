FROM ubuntu:18.04

# install git
RUN apt-get -y update \
 && apt-get install -y git \
 && apt-get install -y curl \
 && apt-get install -y ffmpeg 


# install Azure CLI
RUN mkdir /git 
WORKDIR /git 
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
RUN wget https://aka.ms/downloadazcopy-v10-linux 
#Expand Archive
RUN tar -xvf downloadazcopy-v10-linux
#(Optional) Remove existing AzCopy version
RUN rm /usr/bin/azcopy 
#Move AzCopy to the destination you want to store it
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

ENV PORT 8080
EXPOSE 8080
ENV PORT 80
EXPOSE 80
ENV PORT 443
EXPOSE 443
ENV PORT 1935
EXPOSE 1935

