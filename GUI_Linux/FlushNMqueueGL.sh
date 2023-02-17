#!/bin/bash

# Test file size of NM_FILES_TO_UPLOAD.inf and run FlushNMqueue.py if needed.
# intended to be run as a cron job
# # m h  dom mon dow   command
# 0 20 * * * $HOME/source/NMMA/FlushNMqueue.sh

printf "FlushNMqueueGL.sh 27-Jan, 2023, for GUI RMS Linux, 1265 bytes\n"
printf "Flush NM upload queue if files still need to be uploaded\n\n"

MyStations=(../Stations/*)

for station in ${MyStations[@]}
do
  if [[  "${station##*/}" != "Scripts" ]] ; then
    This_Station=$(sed  's/\.\.\/Stations\///g' <<< ${station})
    echo "Processing station $This_Station"
    
    # Is NM_FILES_TO_UPLOAD.inf is old enough to be sure processing is done?
    old_enough=0
    while [ $old_enough -eq 0 ]
    do
        if test $( find ""$HOME"/RMS_data/$This_Station/NM_FILES_TO_UPLOAD.inf" -mmin +10 ); then
    	old_enough=1
        else
    	env printf "Waiting for NM_FILES_TO_UPLOAD.inf to be old enough to check...\n"
    	env sleep 600
        fi
    done
    
    if [ -s "$HOME"/RMS_data/$This_Station/NM_FILES_TO_UPLOAD.inf ] ; then
       cd "$HOME"/source/NMMA
       printf "Flushing queue of files to upload to NM Server\n"
       python -m FlushNMqueue $This_Station
    else
      printf "No files are queued for upload to NM Server\n"
    fi
  fi
done
