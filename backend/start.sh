#!/bin/bash 
mkdir -p /downloads
mkdir -p /extracts


echo "The platform is available at http://${HOST_IP}"
go run /server.go