#!/bin/bash 

# Setting IFS (input field seprator) value as ","
IFS=','
# Reading the split string into array 
read -ra arr <<< "84.364357,27.601716,84.517822,27.747050"
b_array=arr

echo "$(python -c 'print( arr[0] / 3 )')"