#!/bin/bash

# BackupToUSB.sh
# takes one arg, which is the <stationID>_Date_Time1_Time2 directory name
# of the ArchivedFiles directory.
# assumes that the destination has directories bz2, csv, CapStack, and TimeLapse
# Argument1: ArchivedFiles directory name
# Can also clean out ArchivedFiles directories that are older than $adirs days
#  if $adirs is greater than zero, will also delete log files older than 21 days

printf "BackupToUSB.sh 08-Mar, 2022, byte count ~2447 : backs up data to thumb drive\n"

# set adirs to zero to skip deleting older directories
adirs=7
adir=$((adirs-1))

# set station specific USB drive designation
USB_drive="/media/pi/US0002B_BK/US0002"
station="US0002"

archive_dir="$HOME/RMS_data/ArchivedFiles"
data_dir="$HOME/RMS_data"

# Let's check that first argument. Must be in the ArchivedFiles directory.
if [[ $1 = '' || ! -d "${archive_dir}"/$1 ]] ;
then
    printf 'Argument %s must specify a first-level sub-directory of %s\n' \
        "$1" ${archive_dir} 
    exit 1
fi

# copy fits_count.txt
target="${data_dir}/csv/${station}_fits_counts.txt"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy .csv
target="${data_dir}/csv/$1.csv"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy radiants.txt
target="${data_dir}/csv/$1_radiants.txt"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy or move tar.bz2
target="${archive_dir}/$1_detected.tar.bz2"
if [[ -s ~/RMS_data/FILES_TO_UPLOAD.inf ]] ;
then
    # not empty
    printf "Copying %s...\n" "${target}"
    cp "${target}" "${USB_drive}/bz2"
else
   #  yes, is empty
   printf "Moving %s...\n" "${target}"
   mv "${target}" "${USB_drive}/bz2"
fi

# move TimeLapse.mp4, modified to work with IStream
target="${data_dir}/*.mp4"
printf "Moving %s\n" "${target}"
cd ${data_dir}
for f in *.mp4; do
    mv "$f" "${USB_drive}/TimeLapse"
done

# move Captured_Stack.jpg
target="${data_dir}/$1*_captured.jpg"
printf "Moving %s\n" "${target}"
mv "$HOME"/RMS_data/US*.jpg "${USB_drive}/CapStack"

if [[ $adirs -gt 0 ]] ;
then
    cd "$HOME"/RMS_data/ArchivedFiles
    printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
    find -mtime +$adir -type d | xargs rm -f -r
    printf "Deleting files in RMS_data/logs more than 21 days old\n"
    find "$HOME"/RMS_data/logs/ -type f -mtime +20 -delete;
fi

printf "Done copying data to USB drive %s\n " "${USB_drive}"
