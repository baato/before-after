#!/bin/bash 

echo "Generating  extract..."

today_date=$(date +%Y%m%d)

osmium extract --overwrite --bbox ${2} /downloads/${5}-${1}0101.osm.pbf --output=/extracts/before_${4}.osm.pbf
osmium extract --overwrite --bbox ${2} /downloads/${5}-$today_date.osm.pbf --output=/extracts/after_${4}.osm.pbf