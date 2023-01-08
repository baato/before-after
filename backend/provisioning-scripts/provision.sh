#!/bin/bash 

# Setting IFS (input field seprator) value as ","
IFS=','
# Reading the split string into array
read -ra arr <<< "$2"
b_array=arr
sed -e 's#_CENTERLAT_MAX_#'"${arr[3]}"'#g' -e 's#_CENTERLAT_MIN_#'"${arr[1]}"'#g' -e 's#_CENTERLNG_MAX_#'"${arr[2]}"'#g'  -e 's#_CENTERLNG_MIN_#'"${arr[0]}"'#g' -e 's#_STYLE_#'"${3}"'#g' -e 's#_UUID_#'"${4}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_NAME_#'"${6}"'#g' -e 's#_BEFORE_YEAR_#'"20${1}"'#g' -e 's#_AFTER_YEAR_#'"Present"'#g' /index.html > /appdata/provision/${4}/index.html

mkdir -p /appdata/beforestyles/${4}/
mkdir -p /appdata/afterstyles/${4}/

sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g'  -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"beforetiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/retro.json > /appdata/beforestyles/${4}/retro.json
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"aftertiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/retro.json > /appdata/afterstyles/${4}/retro.json

sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"beforetiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/breeze.json > /appdata/beforestyles/${4}/breeze.json
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"aftertiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/breeze.json > /appdata/afterstyles/${4}/breeze.json

sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"beforetiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/monochrome.json > /appdata/beforestyles/${4}/monochrome.json
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"aftertiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/monochrome.json > /appdata/afterstyles/${4}/monochrome.json

sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g'  -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"beforetiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/osome.json > /appdata/beforestyles/${4}/osome.json
sed -e 's#_HOST_PROTOCOL_#'"${HOST_PROTOCOL:-http:}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_TILE_EPOCH_#'"aftertiles"'#g' -e 's#_UUID_#'"${4}"'#g' /map-styles/osome.json > /appdata/afterstyles/${4}/osome.json

echo "Provision ready!"

