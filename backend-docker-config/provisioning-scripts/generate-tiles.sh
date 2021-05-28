#!/bin/bash 

cd /
tilemaker /before.osm.pbf  --verbose  --output=/appdata/beforetiles/${5}/
tilemaker /after.osm.pbf  --verbose  --output=/appdata/aftertiles/${5}/

cd /appdata/beforetiles/${5}/
gzip -7 -r *

cd /appdata/aftertiles/${5}/
gzip -7 -r *