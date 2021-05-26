#!/bin/bash 

echo "Downloading data..."

wget http://download.geofabrik.de/asia/${6}-${1}0101.osm.pbf -O /old.osm.pbf
wget http://download.geofabrik.de/asia/${6}-latest.osm.pbf -O /new.osm.pbf