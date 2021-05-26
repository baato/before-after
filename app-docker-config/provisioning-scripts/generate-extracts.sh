#!/bin/bash 

echo "Generating  extract..."

osmium extract --overwrite --bbox ${2} /old.osm.pbf --output=/before.osm.pbf
osmium extract --overwrite --bbox ${2} /new.osm.pbf --output=/after.osm.pbf 