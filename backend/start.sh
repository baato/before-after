#!/bin/bash 
mkdir -p /downloads
mkdir -p /extracts

chown -R www-data:www-data /downloads
chown -R www-data:www-data /extracts


echo "The platform is available at http://${HOST_IP}"
go run /server.go