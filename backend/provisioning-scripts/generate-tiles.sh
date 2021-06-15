#!/bin/bash 

media_before=$(date +%Y%m%d%H%M%S)
media_after=$(date +%Y%m%d%H%M%S)

osmium tags-filter -o /extracts/before_$4_highway.osm.pbf /extracts/before_${4}.osm.pbf highway
osmium tags-filter -o /extracts/before_$4_building.osm.pbf /extracts/before_${4}.osm.pbf building 
osmium tags-filter -i -o /extracts/before_$4_others.osm.pbf /extracts/before_${4}.osm.pbf building highway

osmium tags-filter -o /extracts/after_$4_highway.osm.pbf /extracts/after_${4}.osm.pbf highway
osmium tags-filter -o /extracts/after_$4_building.osm.pbf /extracts/after_${4}.osm.pbf building 
osmium tags-filter -i -o /extracts/after_$4_others.osm.pbf /extracts/after_${4}.osm.pbf building highway

cd /

tilemaker /extracts/before_$4_building.osm.pbf    --output=/appdata/beforetiles/${4}.mbtiles
tilemaker /extracts/before_$4_highway.osm.pbf --merge --output=/appdata/beforetiles/${4}.mbtiles
tilemaker /extracts/before_$4_others.osm.pbf --merge --output=/appdata/beforetiles/${4}.mbtiles
mb-util --image_format=pbf /appdata/beforetiles/${4}.mbtiles /appdata/beforetiles/${4} 


tilemaker /extracts/after_$4_building.osm.pbf    --output=/appdata/aftertiles/${4}.mbtiles
tilemaker /extracts/after_$4_highway.osm.pbf --merge --output=/appdata/aftertiles/${4}.mbtiles
tilemaker /extracts/after_$4_others.osm.pbf --merge --output=/appdata/aftertiles/${4}.mbtiles
mb-util --image_format=pbf /appdata/aftertiles/${4}.mbtiles /appdata/aftertiles/${4} 

# tilemaker /extracts/after_${4}.osm.pbf --store /tmp/$media_after_${4}.media  --output=/appdata/aftertiles/${4}/

cd /appdata/beforetiles/${4}/
gzip -7 -r *

cd /appdata/aftertiles/${4}/
gzip -7 -r *

rm /tmp/$media_before_${4}.media
rm /tmp/$media_after_${4}.media