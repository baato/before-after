#!/bin/bash
# Two modes (passed as $10):
#   standard -> ORIGINAL: bbox-extract year file + latest file. Unchanged.
#   history  -> bbox-extract the two Geofabrik DATED files (From/To). Same as
#               standard, just with the dated filenames download-data.sh fetched.
# Output (unchanged downstream): /extracts/before_<uuid>.osm.pbf, after_<uuid>.osm.pbf
set -eo pipefail

MODE="${10:-standard}"
log() { echo "[generate-extracts] $*"; }

# =====================================================================
# STANDARD (unchanged original behaviour)
# =====================================================================
if [ "$MODE" != "history" ]; then
    echo "Generating  extract..."
    today_date=$(date +%Y%m%d)

    osmium extract --overwrite --bbox ${2} /downloads/${5}-${1}0101.osm.pbf -s simple --set-bounds --output=/extracts/before_${4}_unclipped.osm.pbf
    osmosis --read-pbf /extracts/before_${4}_unclipped.osm.pbf --bounding-box clipIncompleteEntities=true --write-pbf /extracts/before_${4}.osm.pbf
    rm /extracts/before_${4}_unclipped.osm.pbf

    osmium extract --overwrite --bbox ${2} /downloads/${5}-$today_date.osm.pbf -s simple --set-bounds --output=/extracts/after_${4}_unclipped.osm.pbf
    osmosis --read-pbf /extracts/after_${4}_unclipped.osm.pbf --bounding-box clipIncompleteEntities=true --write-pbf /extracts/after_${4}.osm.pbf
    rm /extracts/after_${4}_unclipped.osm.pbf

    rm /downloads/${5}-${1}0101.osm.pbf
    rm /downloads/${5}-$today_date.osm.pbf
    exit 0
fi

# =====================================================================
# HISTORY (date range) — bbox-extract the two dated Geofabrik files
# =====================================================================
BBOX="$2"; UUID="$4"; COUNTRY="$5"; BEFORE_DATE="$8"; AFTER_DATE="$9"
[ -n "$AFTER_DATE" ] || AFTER_DATE="latest"
tag_for() { if [ "$1" = "latest" ]; then echo latest; else date -u -d "$1" +%y%m%d; fi; }

extract_one() {  # $1 = date|latest   $2 = before|after
    local d="$1" ep="$2" tag src unclipped out
    tag="$(tag_for "$d")"
    src="/downloads/${COUNTRY}-${tag}.osm.pbf"
    unclipped="/extracts/${ep}_${UUID}_unclipped.osm.pbf"
    out="/extracts/${ep}_${UUID}.osm.pbf"
    [ -s "$src" ] || { log "ERROR: missing dated extract ${src}"; exit 2; }
    osmium extract --overwrite --bbox ${BBOX} "$src" -s simple --set-bounds --output="$unclipped"
    osmosis --read-pbf "$unclipped" --bounding-box clipIncompleteEntities=true --write-pbf "$out"
    rm -f "$unclipped"
    log "built ${out}"
}

extract_one "$BEFORE_DATE" before
extract_one "$AFTER_DATE"  after
log "extracts ready"
