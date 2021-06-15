#!/bin/bash 

## declare an array variable for themes you want to include in data
declare -a arr=("highway=trunk" "highway=primary" "highway=secondary" "highway=tertiary" "highway=unclassifed" "building" "amenity" "landuse" "waterway" "water" "landcover")

## now loop through the above array
for i in "${arr[@]}"
do
   osmium tags-filter -o /extracts/before_$4_$i.osm.pbf /extracts/before_${4}.osm.pbf nwr/$i
done

for i in "${arr[@]}"
do
   osmium tags-filter -o /extracts/after_$4_$i.osm.pbf /extracts/after_${4}.osm.pbf nwr/$i
done

cd /

# merge layers one by one
for i in "${arr[@]}"
do
   tilemaker /extracts/before_$4_$i.osm.pbf --merge    --output=/appdata/beforetiles/${4}.mbtiles
done

# generate tiles from mbtiles
mb-util --image_format=pbf /appdata/beforetiles/${4}.mbtiles /appdata/beforetiles/${4} 


for i in "${arr[@]}"
do
   tilemaker /extracts/after_$4_$i.osm.pbf --merge    --output=/appdata/aftertiles/${4}.mbtiles
done

mb-util --image_format=pbf /appdata/aftertiles/${4}.mbtiles /appdata/aftertiles/${4} 

# gzip the generated tiles
cd /appdata/beforetiles/${4}/
gzip -7 -r *

cd /appdata/aftertiles/${4}/
gzip -7 -r *

# remove intermediate files
for i in "${arr[@]}"
do
   rm /extracts/before_$4_$i.osm.pbf 
   rm /extracts/after_$4_$i.osm.pbf 
done

rm /appdata/beforetiles/${4}.mbtiles
rm /appdata/aftertiles/${4}.mbtiles