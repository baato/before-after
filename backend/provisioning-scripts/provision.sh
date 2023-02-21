#!/bin/bash 

# Setting IFS (input field seprator) value as ","
IFS=','
# Reading the split string into array
read -ra arr <<< "$2"
b_array=arr
sed -e 's#_CENTERLAT_MAX_#'"${arr[3]}"'#g' -e 's#_CENTERLAT_MIN_#'"${arr[1]}"'#g' -e 's#_CENTERLNG_MAX_#'"${arr[2]}"'#g'  -e 's#_CENTERLNG_MIN_#'"${arr[0]}"'#g' -e 's#_STYLE_#'"${3}"'#g' -e 's#_UUID_#'"${4}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_NAME_#'"${6}"'#g' -e 's#_BEFORE_YEAR_#'"20${1}"'#g' -e 's#_AFTER_YEAR_#'"Present"'#g' -e 's#_MAP_ORG_#'"MapTiler"'#g' -e 's#_URL_FOR_MAP_THEME_#'"https://www.maptiler.com/copyright/"'#g' /index.html > /appdata/provision/${4}/index.html

mkdir -p /appdata/beforestyles/${4}/
mkdir -p /appdata/afterstyles/${4}/

# Copy OSM theme style from Maptiles with SED by applying required parameters.
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"beforetiles"'#g' -e 's#_UUID_#'"${4}"'#g' -e 's#_MAP_TILER_KEY_#'"${MAP_TILER_KEY}"'#g'  /map-styles/OpenStreetMap.json > /appdata/beforestyles/${4}/OpenStreetMap.json
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"aftertiles"'#g' -e 's#_UUID_#'"${4}"'#g' -e 's#_MAP_TILER_KEY_#'"${MAP_TILER_KEY}"'#g' /map-styles/OpenStreetMap.json > /appdata/afterstyles/${4}/OpenStreetMap.json

echo "Provision ready!"