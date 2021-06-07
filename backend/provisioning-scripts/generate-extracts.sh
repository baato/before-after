#!/bin/bash 

echo "Generating  extract..."

osmium extract --overwrite --bbox ${2} /downloads/old_${5}-${1}0101.osm.pbf --output=/extracts/before_${5}-${1}0101.osm.pbf
osmium extract --overwrite --bbox ${2} /downloads/new_${5}-latest.osm.pbf --output=/extracts/after_${5}-latest.osm.pbf