#!/bin/bash 

echo "Generating  extract..."

today_date=$(date +%Y%m%d)

osmium extract --overwrite --bbox ${2} /downloads/${5}-${1}0101.osm.pbf -s simple --set-bounds --output=/extracts/before_${4}_unclipped.osm.pbf
osmosis --read-pbf /extracts/before_${4}_unclipped.osm.pbf --bounding-box clipIncompleteEntities=true --write-pbf /extracts/before_${4}.osm.pbf
rm /extracts/before_${4}_unclipped.osm.pbf

osmium extract --overwrite --bbox ${2} /downloads/${5}-$today_date.osm.pbf -s simple --set-bounds --output=/extracts/after_${4}_unclipped.osm.pbf
osmosis --read-pbf /extracts/after_${4}_unclipped.osm.pbf --bounding-box clipIncompleteEntities=true --write-pbf /extracts/after_${4}.osm.pbf
rm /extracts/after_${4}_unclipped.osm.pbf