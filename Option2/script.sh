#!/bin/bash
MyStations=(../Stations/*)
for station in ${MyStations[@]}
do
	This_Station=$(sed  's/\.\.\/Stations\///g' <<< ${station})
	echo "Processing station $This_Station"
	# do some other stuff for each This_Station"
done
