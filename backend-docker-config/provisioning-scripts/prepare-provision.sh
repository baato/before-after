#!/bin/bash 

mkdir -p /appdata/beforetiles/${5}
mkdir -p /appdata/beforestyles

mkdir -p /appdata/aftertiles/${5}
mkdir -p /appdata/afterstyles

mkdir -p /appdata/provision/${5}

chown -R www-data:www-data /appdata/

echo "Preparation completed!"

exit 1