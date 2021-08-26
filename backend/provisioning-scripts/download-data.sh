#!/bin/bash 

echo "Downloading data..."

today_date=$(date +%Y%m%d)

if [ "$5" == "us" -a $1 -lt 21 ]; then
        echo "US REGION"
        if [ ! -f "/downloads/$5-$10101.osm.pbf" ]; then
            wget https://download.geofabrik.de/$7/$5-midwest-$10101.osm.pbf  -O /tmp/$5-midwest-$10101.osm.pbf
            wget https://download.geofabrik.de/$7/$5-northeast-$10101.osm.pbf  -O /tmp/$5-northeast-$10101.osm.pbf
            wget https://download.geofabrik.de/$7/$5-pacific-$10101.osm.pbf  -O /tmp/$5-pacific-$10101.osm.pbf
            wget https://download.geofabrik.de/$7/$5-south-$10101.osm.pbf  -O /tmp/$5-south-$10101.osm.pbf
            wget https://download.geofabrik.de/$7/$5-west-$10101.osm.pbf  -O /tmp/$5-west-$10101.osm.pbf
            
            osmium merge /tmp/$5-midwest-$10101.osm.pbf /tmp/$5-northeast-$10101.osm.pbf /tmp/$5-pacific-$10101.osm.pbf /tmp/$5-south-$10101.osm.pbf /tmp/$5-west-$10101.osm.pbf -o /tmp/$5-$10101-$4.osm.pbf
            mv /tmp/$5-$10101-$4.osm.pbf /downloads/$5-$10101.osm.pbf

            rm /tmp/$5-midwest-$10101.osm.pbf
            rm /tmp/$5-northeast-$10101.osm.pbf
            rm /tmp/$5-pacific-$10101.osm.pbf
            rm /tmp/$5-south-$10101.osm.pbf
            rm /tmp/$5-west-$10101.osm.pbf
        fi

else
    echo "OTHER REGION"
    # move to permanent location from a temporary location only when fully downloaded.
    if [ ! -f "/downloads/$5-$10101.osm.pbf" ]; then
        if ! [[ `wget -S --spider https://download.geofabrik.de/$7/$5-$10101.osm.pbf  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then exit 1; fi
        wget https://download.geofabrik.de/$7/$5-$10101.osm.pbf  -O /tmp/$5-$10101-$4.osm.pbf
        mv /tmp/$5-$10101-$4.osm.pbf /downloads/$5-$10101.osm.pbf
    fi
fi



if [ ! -f "/downloads/$5-$today_date.osm.pbf" ]; then
    echo "LATEST DOWNLOAD"
    if ! [[ `wget -S --spider https://download.geofabrik.de/$7/$5-latest.osm.pbf  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then exit 1; fi
    wget https://download.geofabrik.de/$7/$5-latest.osm.pbf -O  /tmp/$5-$today_date-$4.osm.pbf
    mv /tmp/$5-$today_date-$4.osm.pbf /downloads/$5-$today_date.osm.pbf
fi
