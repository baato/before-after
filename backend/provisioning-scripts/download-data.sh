#!/bin/bash 

echo "Downloading data..."

today_date=$(date +%Y%m%d)


# move to permanent location from a temporary location only when fully downloaded.
if [ ! -f "/downloads/$5-$10101.osm.pbf" ]; then
    wget http://download.geofabrik.de/$7/$5-$10101.osm.pbf  -O /tmp/$5-$10101-$4.osm.pbf
    mv /tmp/$5-$10101-$4.osm.pbf /downloads/$5-$10101.osm.pbf
fi

if [ ! -f "/downloads/$5-$today_date.osm.pbf" ]; then
    wget http://download.geofabrik.de/$7/$5-latest.osm.pbf -O  /tmp/$5-$today_date-$4.osm.pbf
    mv /tmp/$5-$today_date-$4.osm.pbf /downloads/$5-$today_date.osm.pbf
fi
