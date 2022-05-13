#!/bin/bash

# Cleanup.sh: rename to BackupToUSB.sh for stations without a backup USB drive

printf "BackupToUSB = Cleanup.sh 13-May, 2022, byte count 970 : clean out older data\n"

adirs=7
older=7
adir=$((adirs-1))
old=$((older-1))

cd "$HOME"/RMS_data/ArchivedFiles
#printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
find -mtime +$adir -type d | xargs rm -f -r

printf "Deleting tar.bz2 files more than %s days old\n" "${older}" 
find "$HOME"/RMS_data/ArchivedFiles/*.bz2 -type f -mtime +$old -delete;

printf "Deleting TimeLapse.mp4 files more than %s days old\n" "${older}" 
find "$HOME"/RMS_data/*.mp4 -type f -mtime +$old -delete;

printf "Deleting Captured_Stack files more than %s days old\n" "${older}" 
find "$HOME"/RMS_data/*_captured.jpg -type f -mtime +$old -delete;

printf "Deleting files in RMS_data/logs more than 21 days old\n"
find "$HOME"/RMS_data/logs/ -type f -mtime +20 -delete;

printf "Done cleaning up old data\n "
