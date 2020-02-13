#!/bin/bash
# This bash file install apache
# Parameter 1 hostname 
azure_hostname=$1
rtmp_path=$2
storage_account=$3
storage_container=$4
storage_sas_token=$5
#############################################################################
log()
{
	# If you want to enable this logging, uncomment the line below and specify your logging key 
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
	echo "$1" >> /testrtmp/log/install.log
}

#############################################################################
check_os() {
    grep ubuntu /proc/version > /dev/null 2>&1
    isubuntu=${?}
    grep centos /proc/version > /dev/null 2>&1
    iscentos=${?}
    grep redhat /proc/version > /dev/null 2>&1
    isredhat=${?}	
	if [ -f /etc/debian_version ]; then
    isdebian=0
	else
	isdebian=1	
    fi

	if [ $isubuntu -eq 0 ]; then
		OS=Ubuntu
		VER=$(lsb_release -a | grep Release: | sed  's/Release://'| sed -e 's/^[ \t]*//' | cut -d . -f 1)
	elif [ $iscentos -eq 0 ]; then
		OS=Centos
		VER=$(cat /etc/centos-release)
	elif [ $isredhat -eq 0 ]; then
		OS=RedHat
		VER=$(cat /etc/redhat-release)
	elif [ $isdebian -eq 0 ];then
		OS=Debian  # XXX or Ubuntu??
		VER=$(cat /etc/debian_version)
	else
		OS=$(uname -s)
		VER=$(uname -r)
	fi
	
	ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

	log "OS=$OS version $VER Architecture $ARCH"
}


#############################################################################
configure_network(){
# firewall configuration 
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 1935 -j ACCEPT
}
#############################################################################
configure_network_centos(){
# firewall configuration 
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 1935 -j ACCEPT


service firewalld start
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=1935/tcp
firewall-cmd --reload
}



#############################################################################
install_git_ubuntu(){
apt-get -y install git
}
install_git_centos(){
yum -y install git
}





#############################################################################
install_nginx_rtmp(){
# install pre-requisites
apt-get -y install build-essential curl g++
# Download source code
cd /git
apt-get -y update
apt-get -y install libpcre3 libpcre3-dev
apt-get -y install libssl-dev
apt-get -y install zlib1g-dev
#git clone https://github.com/nginx/nginx.git
wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar xvfz nginx-1.16.1.tar.gz
git clone https://github.com/arut/nginx-rtmp-module.git 
cd nginx-1.16.1
./configure --add-module=/git/nginx-rtmp-module
make
make install

log "nginx_rtmp installed"

}

#############################################################################
install_ffmpeg(){
# install pre-requisites
apt-get -y update
apt-get -y install ffmpeg
log "ffmpeg installed"
}


#############################################################################
install_azcli(){
cd /git
 
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

log "azcli installed"
}


#############################################################################
install_azcopy(){
cd /git
wget https://aka.ms/downloadazcopy-v10-linux
 
#Expand Archive
tar -xvf downloadazcopy-v10-linux
 
#(Optional) Remove existing AzCopy version
sudo rm /usr/bin/azcopy
 
#Move AzCopy to the destination you want to store it
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
log "azcopy installed"
}

#############################################################################
install_ffmpeg_service(){
cat <<EOF > /testrtmp/ffmpegloop.sh
while [ : ]
do
folder=\$(date  +"%F-%X.%S")
mkdir /chunks/\$folder
echo mkdir /chunks/\$folder >> /testrtmp/log/ffmpeg.log
/usr/bin/ffmpeg -f flv -i rtmp://127.0.0.1:1935/$1 -c copy -flags +global_header -f segment -segment_time 60 -segment_format_options movflags=+faststart -reset_timestamps 1 -strftime 1 "/chunks/\$folder/%Y-%m-%d_%H-%M-%S_chunk.mp4" 
sleep 5
done
EOF

chmod +x   /testrtmp/ffmpegloop.sh
adduser testrtmpuser --disabled-login

cat <<EOF > /etc/systemd/system/ffmpegloop.service
[Unit]
Description=ffmpeg Loop Service
After=network.target

[Service]
Type=simple
User=testrtmpuser
ExecStart=/bin/sh /testrtmp/ffmpegloop.sh
Restart=on-abort

[Install]
WantedBy=multi-user.targetEOF
EOF
}

#############################################################################
install_azcopy_service(){
cat <<EOF > /testrtmp/azcopyloop.sh
prefixuri='$1'
sastoken="$2"
while [ : ]
do
for mp in /chunks/**/*.mp4
do
if [ \$mp != '/chunks/**/*.mp4' ];
then
echo Processing file: "\$mp"
#echo Token: "\$sastoken"
#echo Url: "\$prefixuri"
echo azcopy cp "\$mp" "\$prefixuri\$mp\$sastoken"
lsof | grep \$mp
if [ ! \${?} -eq 0 ];
then
        echo copying "\$mp"
        azcopy cp "\$mp" "\$prefixuri\$mp\$sastoken"
        rm -f "\$mp"
else
        echo in process "\$mp"
fi
fi
done
sleep 60
done
EOF

}




#############################################################################
install_azcli_service(){
cat <<EOF > /testrtmp/azcliloop.sh
account='$1'
container='$2'
sastoken="$3"
echo account: $account >> /testrtmp/log/azcli.log
echo container: $container  >> /testrtmp/log/azcli.log
echo sastoken: $sastoken   >> /testrtmp/log/azcli.log
while [ : ]
do
for mp in /chunks/**/*.mp4
do
if [ \$mp != '/chunks/**/*.mp4' ];
then
echo az storage blob upload -f "\$mp" -c "\$container" -n "\${mp:1}" --account-name "\$account" --sas-token "\$sastoken" >> /testrtmp/log/azcli.log
lsof | grep \$mp
if [ ! \${?} -eq 0 ];
then
        echo Processing file: "\$mp"  >> /testrtmp/log/azcli.log
        az storage blob upload -f "\$mp" -c "\$container" -n "\${mp:1}" --account-name "\$account" --sas-token "\$sastoken"
        rm -f "\$mp"
        echo file "\$mp" removed >> /testrtmp/log/azcli.log
else
        echo in process "\$mp"
fi
fi
done
sleep 60
done
EOF

chmod +x   /testrtmp/azcliloop.sh
adduser testrtmpuser --disabled-login

cat <<EOF > /etc/systemd/system/azcliloop.service
[Unit]
Description=Azcli Loop Service
After=network.target

[Service]
Type=simple
User=testrtmpuser
ExecStart=/bin/bash /testrtmp/azcliloop.sh
Restart=on-abort


[Install]
WantedBy=multi-user.target
EOF
}

#############################################################################
install_nginx_rtmp_service(){
/usr/local/nginx/sbin/nginx -s stop

cat <<EOF > /usr/local/nginx/conf/nginx.conf
#user  nobody;
worker_processes  1;
error_log  /testrtmp/log/nginxerror.log debug;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        # rtmp stat
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            # you can move stat.xsl to a different location
            root /usr/build/nginx-rtmp-module;
        }

        # rtmp control
        location /control {
            rtmp_control all;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}

rtmp {
    server {
        listen 1935;
        ping 30s;
        notify_method get;
        buflen 5s;

        application live {
            live on;
            interleave on;
            # exec_push ffmpeg -i rtmp://127.0.0.1:1935/live/stream -c copy -f flv /tmp/test.flv ;
            # exec_push ffmpeg -f flv -i rtmp://10.0.1.4:1935/live/stream -c copy -flags +global_header -f segment -segment_time 60 -segment_format_options movflags=+faststart -reset_timestamps 1 /chunks/testnginx%d.mp4  >> /testrtmp/log/ffmpeg.log ;
        }
    }
}
EOF

}






#############################################################################

environ=`env`
# Create folders
mkdir /git
mkdir /temp
mkdir /chunks
chmod +777 /chunks
mkdir /testrtmp
mkdir /testrtmp/log
chmod +777 /testrtmp/log
mkdir /testrtmp/config

# Write access in log subfolder
chmod -R a+rw /testrtmp/log
log "Environment before installation: $environ"

log "Installation script start : $(date)"
log "Net Core Installation: $(date)"
log "#####  azure_hostname: $azure_hostname"
log "#####  rtmp_path: $rtmp_path"
log "#####  storage_account: $storage_account"
log "#####  storage_container: $storage_container"
log "#####  storage_key: $storage_sas_token"
log "Installation script start : $(date)"
check_os
if [ $iscentos -ne 0 ] && [ $isredhat -ne 0 ] && [ $isubuntu -ne 0 ] && [ $isdebian -ne 0 ];
then
    log "unsupported operating system"
    exit 1 
else
	if [ $iscentos -eq 0 ] ; then
	    log "configure network centos"
		configure_network_centos
	    log "install git centos"
		install_git_centos
	elif [ $isredhat -eq 0 ] ; then
	    log "configure network redhat"
		configure_network_centos
	    log "install git redhat"
		install_git_centos
	elif [ $isubuntu -eq 0 ] ; then
	    log "configure network ubuntu"
		configure_network
	    log "install git ubuntu"
		install_git_ubuntu
	elif [ $isdebian -eq 0 ] ; then
	    log "configure network"
		configure_network
	    log "install git debian"
		install_git_ubuntu
	fi
	log "build ffmpeg and nginx_rtmp"
	if [ $isredhat -eq 0 ] ; then
	    log "build ffmpeg nginx_rtmp redhat"
		install_ffmpeg
		install_nginx_rtmp
#		install_azcopy
		install_azcli
	else
	    log "build ffmpeg nginx_rtmp "
		install_ffmpeg
		install_nginx_rtmp
#		install_azcopy
		install_azcli
	fi

	if [ $iscentos -eq 0 ] ; then
	    log "install ffmpeg nginx_rtmp azcli centos"
		install_ffmpeg_service $rtmp_path
		install_nginx_rtmp_service
#		install_azcopy_service $storage_account_prefix  $storage_sas_token
		install_azcli_service $storage_account  $storage_container   $storage_sas_token
	elif [ $isredhat -eq 0 ] ; then
	    log "install ffmpeg nginx_rtmp azcli redhat"
		install_ffmpeg_service $rtmp_path
		install_nginx_rtmp_service
#		install_azcopy_service $storage_account_prefix  $storage_sas_token
		install_azcli_service $storage_account  $storage_container   $storage_sas_token
	elif [ $isubuntu -eq 0 ] ; then
	    log "install ffmpeg nginx_rtmp azcli ubuntu"
		install_ffmpeg_service $rtmp_path
		install_nginx_rtmp_service
#		install_azcopy_service $storage_account_prefix  $storage_sas_token
		install_azcli_service $storage_account  $storage_container   $storage_sas_token
	elif [ $isdebian -eq 0 ] ; then
	    log "install ffmpeg nginx_rtmp azcli debian"
		install_ffmpeg_service $rtmp_path
		install_nginx_rtmp_service
#		install_azcopy_service $storage_account_prefix  $storage_sas_token
		install_azcli_service $storage_account  $storage_container   $storage_sas_token
	fi
	log "Start nginx_rtmp service"
	/usr/local/nginx/sbin/nginx -s stop
	/usr/local/nginx/sbin/nginx
	log "Start ffmpeg service"
	systemctl enable ffmpegloop.service
	systemctl start ffmpegloop.service 
#	log "Start azcopy service"
#	systemctl enable azcopyloop.service
#	systemctl start azcopyloop.service 
	log "Start azcli service"
	systemctl enable azcliloop.service
	systemctl start azcliloop.service 
	log "Installation successful, services nginx_rtmp, ffmpeg and azcli running"
fi
exit 0 

