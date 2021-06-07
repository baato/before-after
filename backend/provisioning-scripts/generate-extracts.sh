#!/bin/bash 

echo "Generating  extract..."

osmium extract --overwrite --bbox ${2} /downloads/old_${4}.osm.pbf --output=/extracts/before_${4}.osm.pbf
osmium extract --overwrite --bbox ${2} /downloads/new_${4}.osm.pbf --output=/extracts/after_${4}.osm.pbf