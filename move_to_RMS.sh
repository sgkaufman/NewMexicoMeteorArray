#!/bin/bash

# This script copies files in /home/pi/NMMA/NewMexicoMeteorArray
# into /home/pi/source/RMS and its subdirectories, as appropriate.

git_dir="/home/pi/source/NMMA/NewMexicoMeteorArray"
RMS_dir="/home/pi/source/RMS"

if [[ ! -d "$git_dir" ]]; then
    printf "Directory %s does not exist, exiting ...\n" "$git_dir"
    exit 1
else
    cd "/home/pi/source/NMMA/NewMexicoMeteorArray"
fi


var=$(cat /etc/os-release | grep 'buster')
if [[ -n "$var" ]]; then
    printf "Copying TimeLapse.sh to %s\n" "$RMS_dir"
    cp ./TimeLapse.sh /home/pi/source/RMS/TimeLapse.sh
    printf "Copying ExternalScript.py to %s/RMS/ExternalScript.py\n" "$RMS_dir"
    cp ./ExternalScript.py "$RMS_dir"/RMS/ExternalScript.py
fi

var=$(cat /etc/os-release | grep 'jessie')
if [[ -n $var ]]; then
    printf "Copying TimeLapse.sh to %s\n" "$RMS_dir"
    cp ./TimeLapse.sh "$RMS_dir"/TimeLapse.sh
    printf "Copying ExternalScript_Python2.py to %s/RMS/ExternalScript.py\n" \
	   "$RMS_dir"
    cp ./ExternalScript_Python2.py "$RMS_dir"/RMS/ExternalScript.py
fi

