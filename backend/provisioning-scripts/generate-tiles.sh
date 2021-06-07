#!/bin/bash 

media_before=$(date +%Y%m%d%H%M%S)
media_after=$(date +%Y%m%d%H%M%S)

cd /
tilemaker /extracts/befor_${4}.osm.pbf  --store /tmp/$media_before_${4}.media --verbose  --output=/appdata/beforetiles/${4}/
tilemaker /extracts/after_${4}.osm.pbf --store /tmp/$media_after_${4}.media --verbose  --output=/appdata/aftertiles/${4}/

cd /appdata/beforetiles/${4}/
gzip -7 -r *

cd /appdata/aftertiles/${4}/
gzip -7 -r *

rm /tmp/$media_before_${4}.media
rm /tmp/$media_after_${4}.media