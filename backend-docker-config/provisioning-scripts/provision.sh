#!/bin/bash 

# Setting IFS (input field seprator) value as ","
IFS=','
# Reading the split string into array
read -ra arr <<< "$2"
b_array=arr
sed -e 's#_CENTERLAT_MAX_#'"${arr[3]}"'#g' -e 's#_CENTERLAT_MIN_#'"${arr[1]}"'#g' -e 's#_CENTERLNG_MAX_#'"${arr[2]}"'#g'  -e 's#_CENTERLNG_MIN_#'"${arr[0]}"'#g' -e 's#_STYLE_#'"${3}"'#g' -e 's#_BAATO_ACCESS_TOKEN_#'"${4}"'#g' -e 's#_UUID_#'"${5}"'#g' -e 's#_HOSTNAME_#'"${HOST_IP}"'#g' -e 's#_NAME_#'"${7}"'#g' -e 's#_BEFORE_YEAR_#'"20${1}"'#g' -e 's#_AFTER_YEAR_#'"Present"'#g' /index.html > /appdata/provision/${5}/index.html

echo "Provision ready!"