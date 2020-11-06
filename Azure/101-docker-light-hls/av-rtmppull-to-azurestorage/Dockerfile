FROM ubuntu:18.04 

# install git
RUN apt-get -y update \
 && apt-get install -y git \
 && apt-get install -y curl \
 && apt-get install -y lsof \
 && apt-get install -y ffmpeg 

# Create folders 
RUN mkdir /git \
&& mkdir /temp \
&& mkdir /chunks \
&& chmod +777 /chunks \
&& mkdir /testav \
&& mkdir /testav/log \
&& chmod +777 /testav/log \
&& mkdir /testav/config

# Install Azure CLI
WORKDIR /git 
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN echo 'input_uri="$INPUT_URI"\n\
while [ : ]\n\
  do\n\
folder=$(date  +"%F-%X.%S")\n\
mkdir /chunks/$folder\n\
echo mkdir /chunks/$folder >> /testav/log/ffmpeg.log \n\
/usr/bin/ffmpeg -f flv -i $input_uri -c copy -flags +global_header -f segment -segment_time 60 -segment_format_options movflags=+faststart -reset_timestamps 1 -strftime 1 "/chunks/$folder/%Y-%m-%d_%H-%M-%S_chunk.mp4" \n\
sleep 5 \n\
done \n' >> /testav/ffmpegloop.sh

RUN chmod +x   /testav/ffmpegloop.sh
RUN adduser testavuser --disabled-login

#RUN echo '[Unit] \n\
#Description=ffmpeg Loop Service \n\
#After=network.target \n\
#[Service] \n\
#Type=simple \n\
#User=testavuser \n\
#ExecStart=/bin/sh /testav/ffmpegloop.sh \n\
#Restart=on-abort \n\
#[Install]  \n\
#WantedBy=multi-user.targetEOF \n' > /etc/systemd/system/ffmpegloop.service



RUN echo 'account=$STORAGE_ACCOUNT \n\
container=$STORAGE_CONTAINER \n\
sastoken=$STORAGE_SASTOKEN \n\
while [ : ]\n\
 do\n\
 for mp in /chunks/**/*.mp4\n\
 do\n\
if [ $mp != \"/chunks/**/*.mp4\" ];\n\
then \n\
echo az storage blob upload -f \"$mp\" -c \"\$container\" -n \"${mp:1}\" --account-name \"$account\" --sas-token \"$sastoken\" >> /testav/log/azcli.log \n\
lsof | grep $mp\n\
if [ ! ${?} -eq 0 ];\n\
then\n\
        az storage blob upload -f $mp -c $container -n ${mp:1} --account-name $account --sas-token $sastoken \n\
        rm -f  $mp \n\
        echo file $mp re moved >> /testav/log/azcli.log\n\
else\n\
        echo in process $mp \n\
fi \n\
fi \n\
done \n\
sleep 60 \n\
done \n' > /testav/azcliloop.sh

RUN chmod +x   /testav/azcliloop.sh


#RUN echo '[Unit] \n\
#Description=Azcli Loop Service \n\
#After=network.target \n\
#[Service] \n\
#Type=simple \n\
#User=testavuser \n\
#ExecStart=/bin/bash /testav/azcliloop.sh \n\
#Restart=on-abort \n\
#[Install] \n\
#WantedBy=multi-user.target \n' > /etc/systemd/system/azcliloop.service


ENV INPUT_URI "rtmp://127.0.0.1:1935/live/stream"
ENV STORAGE_ACCOUNT "blobstoragebackup"
ENV STORAGE_CONTAINER "testrtmp"
ENV STORAGE_SASTOKEN "?sv=2019-10-10&st=2020-11-05T15%3A36%3A35Z&se=2030-11-06T15%3A36%3A00Z&sr=c&sp=racwdl&sig=Tuq0xBpej61AP0%2BJetD9cJBIOkaHrPCVgU4t60Vp7Rg%3D"



COPY docker-entrypoint.sh /
RUN chmod +755 /docker-entrypoint.sh 
ENTRYPOINT ["/docker-entrypoint.sh"]