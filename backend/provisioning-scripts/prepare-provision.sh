#!/bin/bash 

mkdir -p /appdata/beforetiles/
mkdir -p /appdata/beforestyles

mkdir -p /appdata/aftertiles/
mkdir -p /appdata/afterstyles

mkdir -p /appdata/provision/${4}

chown -R www-data:www-data /appdata/

echo "Preparation completed!"
