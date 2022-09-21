#!/bin/bash

MyStations=(../Stations/*)
for station in ${MyStations[@]}
do
	This_Station=$(sed  's/\.\.\/Stations\///g' <<< ${station})
	tail -n 7 $HOME/RMS_data/$This_Station/csv/*_fits_counts.txt
	echo ' '
	#IP=$(sed  's/\.\.\/Stations\/US0//g' <<< ${station})
	#echo "Processing station $This_Station, with camera IP: $IP"
done

start=$(head -1 /home/pi/RMS_data/logs/CaptureTimes.log)
printf "Next start time: %s \n" "$start"
read -p "Pausing for 20 seconds, hit Enter key to quit" -t 20

