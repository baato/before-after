#!/bin/bash
set -o pipefail

UUID="${4}"

## tag categories to include in the tiles
declare -a arr=(
    "aerialway" "aerodrome" "aeroway" "amenity" "atm" "barrier" "boundary"
    "building" "healthcare" "highway" "historic" "landcover" "landuse"
    "leisure" "military" "natural" "park" "place" "railway" "shop" "sport"
    "tourism" "water" "waterway"
)

echo "[tiles] start uuid=${UUID}"

[ -f "/extracts/before_${UUID}.osm.pbf" ] || { echo "[tiles] ERROR: missing before extract"; exit 1; }
[ -f "/extracts/after_${UUID}.osm.pbf" ]  || { echo "[tiles] ERROR: missing after extract"; exit 1; }

# 1) split each epoch into per-category, renumbered pbfs
filter_epoch() {
    local epoch="$1"
    for i in "${arr[@]}"; do
        osmium tags-filter --overwrite -o "/extracts/temp_${epoch}_${UUID}_${i}.osm.pbf" "/extracts/${epoch}_${UUID}.osm.pbf" "nwr/${i}"
        osmium renumber --overwrite -o "/extracts/${epoch}_${UUID}_${i}.osm.pbf" "/extracts/temp_${epoch}_${UUID}_${i}.osm.pbf"
        rm -f "/extracts/temp_${epoch}_${UUID}_${i}.osm.pbf"
    done
}

echo "[tiles] filtering categories (before)"
filter_epoch before
echo "[tiles] filtering categories (after)"
filter_epoch after

cd /

# 2) merge categories into a single mbtiles per epoch
build_epoch() {
    local epoch="$1"
    local out="/tmp/${UUID}_${epoch}tiles.mbtiles"
    rm -f "${out}"
    for i in "${arr[@]}"; do
        local f="/extracts/${epoch}_${UUID}_${i}.osm.pbf"
        [ -f "${f}" ] || continue
        echo "[tiles] ${epoch}: merge ${i}"
        # one empty/edge category must not abort the whole build
        tilemaker "${f}" --merge --compact --output="${out}" || echo "[tiles] ${epoch}: skipped ${i}"
        rm -f "${f}"
    done
    if [ ! -f "${out}" ]; then
        echo "[tiles] ERROR: no ${epoch} tiles produced"
        exit 1
    fi
    # move into the watched dir only once fully written (mbtileserver fs-watch)
    mv "${out}" "/appdata/${epoch}tiles/${UUID}.mbtiles"
    echo "[tiles] wrote /appdata/${epoch}tiles/${UUID}.mbtiles"
}

build_epoch before
build_epoch after

rm -f "/extracts/before_${UUID}.osm.pbf" "/extracts/after_${UUID}.osm.pbf"

echo "[tiles] done"
