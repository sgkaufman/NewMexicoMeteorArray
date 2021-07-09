#!/bin/bash

# Test file size of NM_FILES_TO_UPLOAD.inf and run FlushNMqueue.py if needed.
# intended to be run as a cron job
# # m h  dom mon dow   command
#  40 14-18 * * * $HOME/source/RMS/FlushNMqueue.sh

printf "\nFlushNMqueue.sh 09-Jul, 2021, byte count 864 : Flush NM upload queue if needed\n"

# Is NM_FILES_TO_UPLOAD.inf is old enough to be sure processing is done?

old_enough=0
while [ $old_enough -eq 0 ]
do
    if test $( find "$HOME/RMS_data/NM_FILES_TO_UPLOAD.inf" -mmin +10 ); then
	old_enough=1
    else
	env printf "Waiting for NM_FILES_TO_UPLOAD.inf to be old enough to check...\n"
	env sleep 600
    fi
done

if [ -s $HOME/RMS_data/NM_FILES_TO_UPLOAD.inf ] ; then
   cd $HOME/source/RMS
   printf "Flushing queue of files to upload to NM Server\n"
   python -m RMS.FlushNMqueue
else
   printf "No files are queued for upload to NM Server\n"
fi
