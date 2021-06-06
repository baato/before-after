#!/bin/bash 

media_before=$(date +%Y%m%d%H%M%S)
media_after=$(date +%Y%m%d%H%M%S)

cd /
tilemaker /before.osm.pbf  --store /tmp/$media_before.media --verbose  --output=/appdata/beforetiles/${4}/
tilemaker /after.osm.pbf --store /tmp/$media_after.media --verbose  --output=/appdata/aftertiles/${4}/

cd /appdata/beforetiles/${4}/
gzip -7 -r *

cd /appdata/aftertiles/${4}/
gzip -7 -r *

rm /tmp/media_before
rm /tmp/media_after