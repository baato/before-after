#!/bin/bash 

echo "Go server running at port 8848..."
go run /server.go



# rm -R /appdata/beforetiles/
# rm -R /appdata/aftertiles/

# mkdir -p /appdata/beforetiles
# mkdir -p /appdata/beforestyles



# mkdir -p /appdata/aftertiles
# mkdir -p /appdata/afterstyles



# chown -R www-data:www-data /appdata/

# cp /beforestyles.json /appdata/beforestyles/style.json
# cp /afterstyles.json /appdata/afterstyles/style.json

# # sed -e 's#_TILES_EPOCH_#'"beforetiles"'#g' /retro_template.json > /appdata/beforestyles/retro.json
# # sed -e 's#_TILES_EPOCH_#'"aftertiles"'#g' /retro_template.json > /appdata/afterstyles/retro.json

# # sed -e 's#_TILES_EPOCH_#'"beforetiles"'#g' /breeze_template.json > /appdata/beforestyles/breeze.json
# # sed -e 's#_TILES_EPOCH_#'"aftertiles"'#g' /breeze_template.json > /appdata/afterstyles/breeze.json



# wget http://download.geofabrik.de/asia/nepal-${YEAR}0101.osm.pbf -O /old.osm.pbf
# wget http://download.geofabrik.de/asia/nepal-latest.osm.pbf -O /new.osm.pbf
# osmium extract --overwrite --bbox ${BBOX} /old.osm.pbf --output=/before.osm.pbf
# osmium extract --overwrite --bbox ${BBOX} /new.osm.pbf --output=/after.osm.pbf 

# # Setting IFS (input field seprator) value as ","
# IFS=','
# # Reading the split string into array
# read -ra arr <<< "$BBOX"
# b_array=arr
# sed -e 's#_CENTERLAT_#'"${arr[3]}"'#g' -e 's#_CENTERLNG_#'"${arr[2]}"'#g' -e 's#_STYLE_#'"${STYLE}"'#g' -e 's#_BAATO_ACCESS_TOKEN_#'"${BAATO_ACCESS_TOKEN}"'#g'  /index.html > /appdata/index.html

# cd /
# tilemaker /before.osm.pbf  --verbose  --output=/appdata/beforetiles/
# tilemaker /after.osm.pbf  --verbose  --output=/appdata/aftertiles/

# cd /appdata/beforetiles/
# gzip -7 -r *

# cd /appdata/aftertiles/
# gzip -7 -r *