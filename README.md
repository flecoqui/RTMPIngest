# Azure RTMP Ingest

Overview
--------------

This repository contains the ARM Templates to ingest Live RTMP stream and store audio/video chunks in Azure Storage. This Live RTMP ingest is based on NGINX RTMP and FFMPEG.


- [**RTMP Ingest ARM Template with source code**](https://github.com/flecoqui/RTMPIngest/tree/master/Azure/101-vm): ARM Template to deploy an RTMP Ingest based on NGINX RTMP and FFMPEG built from the source code in a virtual machine running either ubuntu or debian.

- [**RTMP Ingest ARM Template**](https://github.com/flecoqui/RTMPIngest/tree/master/Azure/101-vm-light): ARM Template to deploy an RTMP Ingest based on NGINX RTMP and FFMPEG in a virtual machine running either ubuntu, debian, centos or redhat.


![](https://raw.githubusercontent.com/flecoqui/RTMPIngest/master/Azure/101-vm/Docs/1-architecture.png)