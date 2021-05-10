m#!/bin/bash

# Version 0.2, 01-Mar-2021. Byte count = 1693
# This script copies files in /home/pi/NMMA/NewMexicoMeteorArray
# into /home/pi/source/RMS and its subdirectories, as determined
# by the Raspbian OS version specified in file /etc/os-release.

# Sanity check
if [[ ! -f /etc/os-release ]]; then
    echo "File /etc/os-release does not exist, exiting ..."
    exit 1
fi

git_dir="/home/pi/source/NMMA/NewMexicoMeteorArray"
RMS_dir="/home/pi/source/RMS"

if [[ ! -d "$git_dir" ]]; then
    printf "Directory %s does not exist, exiting ...\n" "$git_dir"
    exit 1
else
    cd "/home/pi/source/NMMA/NewMexicoMeteorArray"
fi

printf "Copying TimeLapse.sh to %s\n" "$RMS_dir"
cp ./TimeLapse.sh /home/pi/source/RMS/TimeLapse.sh
printf "Copying ExternalScript.py to %s/RMS/ExternalScript.py\n" \
       "$RMS_dir"
cp ./ExternalScript.py "$RMS_dir"/RMS/ExternalScript.py
printf "Copying RecordWatchdog.sh to %s/Scripts/RecordWatchdog.sh\n" \
       "$RMS_dir"
cp ./RecordWatchdog.sh "$RMS_dir"/Scripts/RecordWatchdog.sh
printf "Copying StartCaptureWatchdog.sh to %s/StartCaptureWatchdog.sh\n" \
       "$RMS_dir"
cp ./StartCaptureWatchdog.sh "$RMS_dir"/StartCaptureWatchdog.sh
printf "Copying WriteCapture.py to %s/RMS/WriteCapture.py\n" \
       "$RMS_dir"
cp ./WriteCapture.py "$RMS_dir"/RMS/WriteCapture.py
printf "Copying FlushNMqueue.py to %s/RMS/FlushNMqueue.py\n" \
       "$RMS_dir"
cp ./FlushNMqueue.py "$RMS_dir"/RMS/FlushNMqueue.py
printf "Copying RecordWatchdog.sh to %s/Scripts/RecordWatchdog.sh\n" \
       "$RMS_dir"
cp ./RecordWatchdog.sh "$RMS_dir"/Scripts/FlushNMqueue.py

