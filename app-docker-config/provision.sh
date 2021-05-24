#!/bin/bash 

mkdir -p /appdata/beforetiles/${5}
mkdir -p /appdata/beforestyles

mkdir -p /appdata/aftertiles/${5}
mkdir -p /appdata/afterstyles

mkdir -p /appdata/provision/${5}

chown -R www-data:www-data /appdata/

cp /beforestyles.json /appdata/beforestyles/style.json
cp /afterstyles.json /appdata/afterstyles/style.json


wget http://download.geofabrik.de/asia/${6}-${1}0101.osm.pbf -O /old.osm.pbf
wget http://download.geofabrik.de/asia/${6}-latest.osm.pbf -O /new.osm.pbf

osmium extract --overwrite --bbox ${2} /old.osm.pbf --output=/before.osm.pbf
osmium extract --overwrite --bbox ${2} /new.osm.pbf --output=/after.osm.pbf 

# Setting IFS (input field seprator) value as ","
IFS=','
# Reading the split string into array 
read -ra arr <<< "$2"
b_array=arr
sed -e 's#_CENTERLAT_MAX_#'"${arr[3]}"'#g' -e 's#_CENTERLAT_MIN_#'"${arr[1]}"'#g' -e 's#_CENTERLNG_MAX_#'"${arr[2]}"'#g'  -e 's#_CENTERLNG_MIN_#'"${arr[0]}"'#g' -e 's#_STYLE_#'"${3}"'#g' -e 's#_BAATO_ACCESS_TOKEN_#'"${4}"'#g' -e 's#_UUID_#'"${5}"'#g'  /index.html > /appdata/provision/${5}/index.html

cd /
tilemaker /before.osm.pbf  --verbose  --output=/appdata/beforetiles/${5}/
tilemaker /after.osm.pbf  --verbose  --output=/appdata/aftertiles/${5}/

cd /appdata/beforetiles/${5}/
gzip -7 -r *

cd /appdata/aftertiles/${5}/
gzip -7 -r *

echo "http://download.geofabrik.de/asia/nepal-${1}0101.osm.pbf"