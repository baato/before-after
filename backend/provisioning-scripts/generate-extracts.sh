#!/bin/bash
set -eo pipefail

YEAR="${1}"
BBOX="${2}"
UUID="${4}"
COUNTRY="${5}"

today_date=$(date +%Y%m%d)

echo "[extract] uuid=${UUID} incoming bbox=${BBOX}"

# The frontend sends the bbox as four numbers (two lng/lat corners) but the
# corner order can differ (search uses Photon's [W,N,E,S], drawn boxes come as
# min/max). osmium --bbox strictly wants LEFT,BOTTOM,RIGHT,TOP (minlng,minlat,
# maxlng,maxlat), so normalise here to be safe regardless of input order.
IFS=',' read -r c0 c1 c2 c3 <<< "${BBOX}"
read -r minlng maxlng < <(awk -v a="$c0" -v b="$c2" 'BEGIN{if(a<b)print a,b; else print b,a}')
read -r minlat maxlat < <(awk -v a="$c1" -v b="$c3" 'BEGIN{if(a<b)print a,b; else print b,a}')
OSM_BBOX="${minlng},${minlat},${maxlng},${maxlat}"
echo "[extract] normalised osmium bbox=${OSM_BBOX}"

before_src="/downloads/${COUNTRY}-${YEAR}0101.osm.pbf"
after_src="/downloads/${COUNTRY}-${today_date}.osm.pbf"
[ -f "${before_src}" ] || { echo "[extract] ERROR: missing ${before_src}"; exit 1; }
[ -f "${after_src}" ]  || { echo "[extract] ERROR: missing ${after_src}"; exit 1; }

echo "[extract] before extract + clip"
osmium extract --overwrite --bbox "${OSM_BBOX}" "${before_src}" -s simple --set-bounds --output="/extracts/before_${UUID}_unclipped.osm.pbf"
osmosis --read-pbf "/extracts/before_${UUID}_unclipped.osm.pbf" --bounding-box clipIncompleteEntities=true --write-pbf "/extracts/before_${UUID}.osm.pbf"
rm -f "/extracts/before_${UUID}_unclipped.osm.pbf"

echo "[extract] after extract + clip"
osmium extract --overwrite --bbox "${OSM_BBOX}" "${after_src}" -s simple --set-bounds --output="/extracts/after_${UUID}_unclipped.osm.pbf"
osmosis --read-pbf "/extracts/after_${UUID}_unclipped.osm.pbf" --bounding-box clipIncompleteEntities=true --write-pbf "/extracts/after_${UUID}.osm.pbf"
rm -f "/extracts/after_${UUID}_unclipped.osm.pbf"

# Remove the large country downloads now that the extracts exist
rm -f "${before_src}" "${after_src}"

echo "[extract] done"
