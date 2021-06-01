#!/bin/bash 

echo "Downloading data..."

wget http://download.geofabrik.de/asia/${5}-${1}0101.osm.pbf -O /old.osm.pbf
wget http://download.geofabrik.de/asia/${5}-latest.osm.pbf -O /new.osm.pbf