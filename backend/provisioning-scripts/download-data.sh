#!/bin/bash
# Two modes (passed as $10):
#   standard -> ORIGINAL Geofabrik flow (year vs latest). Unchanged.
#   history  -> Geofabrik DATED extracts for the From/To dates (region-YYMMDD.osm.pbf).
#               Same mechanism/size as standard; only the two dated files are fetched.
#               Public Geofabrik keeps ~90 days of dated snapshots (older -> 404).
#
# args: $1 year $2 bbox $3 style $4 uuid $5 country $6 name $7 continent
#       $8 beforeDate(YYYY-MM-DD) $9 afterDate(YYYY-MM-DD|latest) ${10} mode
set -eo pipefail

MODE="${10:-standard}"

# =====================================================================
# STANDARD (unchanged original behaviour)
# =====================================================================
if [ "$MODE" != "history" ]; then
    echo "Downloading data..."
    today_date=$(date +%Y%m%d)

    if [ ! -f "/downloads/$5-$10101.osm.pbf" ]; then
        if ! [[ `wget -S --spider https://download.geofabrik.de/$7/$5-$10101.osm.pbf  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then exit 1; fi
        wget https://download.geofabrik.de/$7/$5-$10101.osm.pbf  -O /tmp/$5-$10101-$4.osm.pbf
        mv /tmp/$5-$10101-$4.osm.pbf /downloads/$5-$10101.osm.pbf
    fi

    if [ ! -f "/downloads/$5-$today_date.osm.pbf" ]; then
        if ! [[ `wget -S --spider https://download.geofabrik.de/$7/$5-latest.osm.pbf  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then exit 1; fi
        wget https://download.geofabrik.de/$7/$5-latest.osm.pbf -O  /tmp/$5-$today_date-$4.osm.pbf
        mv /tmp/$5-$today_date-$4.osm.pbf /downloads/$5-$today_date.osm.pbf
    fi
    exit 0
fi

# =====================================================================
# HISTORY (date range) — Geofabrik dated extracts, clipped later to bbox
# =====================================================================
COUNTRY="$5"; CONTINENT="$7"; UUID="$4"; BEFORE_DATE="$8"; AFTER_DATE="$9"
log() { echo "[download-data] $*"; }

[ -n "$COUNTRY" ] && [ -n "$CONTINENT" ] || { log "ERROR: no region for this location (pick a place from the search box)."; exit 2; }
[ -n "$BEFORE_DATE" ] || { log "ERROR: no 'from' date"; exit 2; }
[ -n "$AFTER_DATE" ]  || AFTER_DATE="latest"

# tag for a date: 'latest' or YYMMDD (Geofabrik dated-file naming)
tag_for() { if [ "$1" = "latest" ]; then echo latest; else date -u -d "$1" +%y%m%d; fi; }

ensure() {  # $1 = date|latest ; ensures /downloads/<country>-<tag>.osm.pbf exists
    local d="$1" tag url out
    tag="$(tag_for "$d")" || { log "ERROR: bad date '$d'"; return 3; }
    url="https://download.geofabrik.de/${CONTINENT}/${COUNTRY}-${tag}.osm.pbf"
    out="/downloads/${COUNTRY}-${tag}.osm.pbf"
    if [ -f "$out" ]; then log "cached ${out}"; return 0; fi
    if ! wget -S --spider "$url" 2>&1 | grep -q 'HTTP/1.1 200 OK'; then
        log "ERROR: ${url} not available."
        log "       Public Geofabrik keeps only ~90 days of dated snapshots — pick a more recent date."
        return 4
    fi
    log "downloading ${url}"
    wget "$url" -O "/tmp/${COUNTRY}-${tag}-${UUID}.osm.pbf"
    mv "/tmp/${COUNTRY}-${tag}-${UUID}.osm.pbf" "$out"
}

ensure "$BEFORE_DATE" || exit 4
ensure "$AFTER_DATE"  || exit 4
log "dated extracts ready (${BEFORE_DATE} -> ${AFTER_DATE})"
