#!/bin/bash 

echo "Downloading data..."

wget http://download.geofabrik.de/asia/${5}-${1}0101.osm.pbf -O /downloads/old_${5}-${1}0101.osm.pbf
wget http://download.geofabrik.de/asia/${5}-latest.osm.pbf -O /downloads/new_${5}-latest.osm.pbf