#!/bin/bash

# Cleanup.sh: rename to BackupToUSB.sh for stations without a backup USB drive

printf "BackupToUSB = Cleanup.sh 04-May, 2023, byte count 1154: clean out older data\n"

# delete older ArchivedFiles directories
adirs=10
adir=$((adirs-1))

# delete older CapturedFiles directories
cdirs=10
cdir=$((cdirs-1))

# delete older mp4 video files and older tar.bz2 archives
older=10
old=$((older-1))

cd "$HOME"/RMS_data/ArchivedFiles
#printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
find -mtime +$adir -type d | xargs rm -f -r

printf "Deleting tar.bz2 files more than %s days old\n" "${older}" 
find "$HOME"/RMS_data/ArchivedFiles/*.bz2 -type f -mtime +$old -delete;

cd "$HOME"/RMS_data/CapturedFiles
printf "Deleting CapturedFiles directories more than %s days old\n" "${cdirs}"
find -mtime +$cdir -type d | xargs rm -f -r 

printf "Deleting TimeLapse.mp4 files more than %s days old\n" "${older}" 
find "$HOME"/RMS_data/*.mp4 -type f -mtime +$old -delete;

printf "Deleting files in RMS_data/logs more than 21 days old\n"
find "$HOME"/RMS_data/logs/ -type f -mtime +20 -delete;

printf "Done deleting old data\n "
