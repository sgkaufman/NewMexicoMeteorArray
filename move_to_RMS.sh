#!/bin/bash

# Version 0.2, 25-Feb-2021. Byte count = 1356
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

var=$( grep -Eo 'buster|jessie' /etc/os-release )
if [[ -n "$var" ]]; then
    printf "grepped the following: %s\n" "$var"
    case ${var:0:6} in
	buster )
	    printf "Copying TimeLapse.sh to %s\n" "$RMS_dir"
	    cp ./TimeLapse.sh /home/pi/source/RMS/TimeLapse.sh
	    printf "Copying ExternalScript.py to %s/RMS/ExternalScript.py\n" "$RMS_dir"
	    cp ./ExternalScript.py "$RMS_dir"/RMS/ExternalScript.py
	    ;;
	jessie )
	    printf "Copying TimeLapse.sh to %s\n" "$RMS_dir"
	    cp ./TimeLapse.sh "$RMS_dir"/TimeLapse.sh
	    printf "Copying ExternalScript_Python2.py to %s/RMS/ExternalScript.py\n" \
	   "$RMS_dir"
	    cp ./ExternalScript_Python2.py "$RMS_dir"/RMS/ExternalScript.py
	    ;;
    esac
else
    echo "Raspbian OS neither buster nor jessie. Strange ..."
fi
