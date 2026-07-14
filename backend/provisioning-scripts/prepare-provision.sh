#!/bin/bash
set -eo pipefail

UUID="${4}"

echo "[prepare] preparing directories for uuid=${UUID}"

# base data dirs (also created by start.sh / compose, kept here for safety)
mkdir -p /downloads /extracts

# tile + style + provision output dirs
mkdir -p /appdata/beforetiles /appdata/aftertiles
mkdir -p /appdata/beforestyles/"${UUID}" /appdata/afterstyles/"${UUID}"
mkdir -p /appdata/provision/"${UUID}"

echo "[prepare] done"
