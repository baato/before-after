#!/bin/bash 

echo "Downloading data..."

today_date=$(date +%Y%m%d)

wget http://download.geofabrik.de/asia/${5}-${1}0101.osm.pbf -nc  -O /downloads/${5}-${1}0101.osm.pbf
wget http://download.geofabrik.de/asia/${5}-latest.osm.pbf -nc -O  /downloads/${5}-$today_date.osm.pbf