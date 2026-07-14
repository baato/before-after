#!/bin/bash
set -eo pipefail

YEAR="${1}"
UUID="${4}"
COUNTRY="${5}"
CONTINENT="${7}"

today_date=$(date +%Y%m%d)
base="https://download.geofabrik.de/${CONTINENT}"

echo "[download] country=${COUNTRY} continent=${CONTINENT} year=20${YEAR}"

before_file="/downloads/${COUNTRY}-${YEAR}0101.osm.pbf"
after_file="/downloads/${COUNTRY}-${today_date}.osm.pbf"

# Fetch $1 -> $2 using a fast multi-connection, resumable download when aria2
# is available (Geofabrik/Hetzner support range requests), else fall back to
# wget with resume. Downloads to a .part file and only moves into place on
# success so a partial file is never treated as a valid cache hit.
download() {
    local url="$1"
    local dest="$2"
    local dir name part
    dir="$(dirname "${dest}")"
    name="$(basename "${dest}")"
    part="${name}.part"

    echo "[download] fetching ${url}"

    if command -v aria2c >/dev/null 2>&1; then
        # -x/-s: up to 16 parallel connections; -c: resume; -k1M: split size
        aria2c \
            --max-connection-per-server=16 \
            --split=16 \
            --min-split-size=1M \
            --continue=true \
            --auto-file-renaming=false \
            --allow-overwrite=true \
            --file-allocation=none \
            --summary-interval=5 \
            --console-log-level=warn \
            --dir="${dir}" \
            --out="${part}" \
            "${url}" || { echo "[download] ERROR: could not download ${url}"; exit 1; }
    else
        if ! wget -q --spider "${url}"; then
            echo "[download] ERROR: file not found on Geofabrik: ${url}"
            echo "[download] (check country='${COUNTRY}' / continent='${CONTINENT}' are valid Geofabrik paths)"
            exit 1
        fi
        wget --continue --progress=dot:giga "${url}" -O "${dir}/${part}"
    fi

    mv "${dir}/${part}" "${dest}"
    echo "[download] saved ${dest}"
}

# historic snapshot (Jan 1 of the chosen year) - immutable, cached forever
if [ ! -f "${before_file}" ]; then
    download "${base}/${COUNTRY}-${YEAR}0101.osm.pbf" "${before_file}"
else
    echo "[download] cached ${before_file}"
fi

# latest snapshot - cached per day
if [ ! -f "${after_file}" ]; then
    download "${base}/${COUNTRY}-latest.osm.pbf" "${after_file}"
else
    echo "[download] cached ${after_file}"
fi

echo "[download] done"
