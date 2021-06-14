#!/bin/bash 

mkdir -p /appdata/beforetiles/${4}
mkdir -p /appdata/beforestyles

mkdir -p /appdata/aftertiles/${4}
mkdir -p /appdata/afterstyles

mkdir -p /appdata/provision/${4}

chown -R www-data:www-data /appdata/

echo "Preparation completed!"
