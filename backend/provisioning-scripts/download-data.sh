#!/bin/bash
set -eo pipefail

# args from the Go worker: $1=year(2-digit) $2=bbox $3=style $4=uuid
#                          $5=country(geofabrik basename) $6=name $7=continent
YEAR="${1}"
UUID="${4}"
COUNTRY="${5}"
CONTINENT="${7}"

today_date=$(date +%Y%m%d)
base="https://download.geofabrik.de/${CONTINENT}"
UA="Mozilla/5.0 (compatible; baato-before-after/1.0; +https://baato.io)"

before_file="/downloads/${COUNTRY}-${YEAR}0101.osm.pbf"
after_file="/downloads/${COUNTRY}-${today_date}.osm.pbf"

echo "[download] country=${COUNTRY} continent=${CONTINENT} year=20${YEAR}"

# Does a URL resolve to HTTP 200 (without downloading the body)?
url_exists() {
    wget -q --spider --tries=2 --timeout=30 --user-agent="${UA}" "$1"
}

# Robustly fetch $1 -> $2.
#
# IMPORTANT: Geofabrik rate-limits per client IP and returns HTTP 502 to
# aggressive multi-connection download managers (aria2 -x16 etc.). Extra
# parallel connections do NOT increase throughput on Geofabrik and are the
# reason the previous version looped on "status=502". So we use a SINGLE
# resumable connection, with our own retry + exponential backoff for genuine
# transient 5xx blips.
fetch() {
    local url="$1" dest="$2"
    local tmp="/tmp/$(basename "$dest").${UUID}.part"
    local try max=6 wait=5

    # Fail fast (with a helpful message) if the file simply isn't published,
    # instead of hammering the server forever.
    if ! url_exists "${url}"; then
        echo "[download] ERROR: not available on Geofabrik: ${url}"
        echo "[download] Geofabrik's public server keeps only recent dated"
        echo "[download] snapshots (about the last 90 days) plus '-latest'."
        echo "[download] A historic date like 20${YEAR}-01-01 may no longer be"
        echo "[download] published there. Pick a more recent year, or use the"
        echo "[download] authenticated osm-internal.download.geofabrik.de for old history."
        return 2
    fi

    for ((try=1; try<=max; try++)); do
        echo "[download] (${try}/${max}) ${url}"
        if wget -c --tries=1 --timeout=120 --user-agent="${UA}" \
                --progress=dot:giga "${url}" -O "${tmp}"; then
            mv "${tmp}" "${dest}"
            echo "[download] saved ${dest} ($(du -h "${dest}" 2>/dev/null | cut -f1))"
            return 0
        fi
        echo "[download] attempt ${try} failed (transient 5xx / throttle); retry in ${wait}s"
        sleep "${wait}"
        wait=$(( wait * 2 )); [ "${wait}" -gt 60 ] && wait=60
    done

    echo "[download] ERROR: gave up on ${url} after ${max} attempts"
    return 1
}

# historic snapshot (Jan 1 of the chosen year) — cached across runs
if [ ! -f "${before_file}" ]; then
    fetch "${base}/${COUNTRY}-${YEAR}0101.osm.pbf" "${before_file}"
else
    echo "[download] cached ${before_file}"
fi

# latest snapshot — cached per-day
if [ ! -f "${after_file}" ]; then
    fetch "${base}/${COUNTRY}-latest.osm.pbf" "${after_file}"
else
    echo "[download] cached ${after_file}"
fi

echo "[download] done"
