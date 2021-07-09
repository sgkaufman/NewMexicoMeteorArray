#!/bin/bash

# BackupToUSB.sh
# takes one arg, which is the <stationID>_Date_Time1_Time2 directory name
# of the ArchivedFiles directory.
# assumes that the destination has directories bz2, csv, CapStack, and TimeLapse
# Argument1: ArchivedFiles directory name

printf "BackupToUSB.sh 09-Jul, 2021, byte count ~1634 : backs up data to thumb drive\n"

# set station specific USB drive designation
USB_drive="/media/pi/US0002B_BK/US0002"
station="US0002"

archive_dir=""$HOME"/RMS_data/ArchivedFiles"
data_dir=""$HOME"/RMS_data"

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

# copy tar.bz2
target="${archive_dir}/$1_detected.tar.bz2"
printf "Copying %s...\n" "${target}"
cp "${target}" "${USB_drive}/bz2"

# move TimeLapse.mp4
target="${data_dir}/$1.mp4"
printf "Moving %s\n" "${target}"
mv "${target}" "${USB_drive}/TimeLapse"

# move Captured_Stack.jpg
target="${data_dir}/$1*_captured.jpg"
printf "Moving %s\n" "${target}"
mv "$HOME"/Desktop/RMS_data/US*.jpg "${USB_drive}/CapStack"

printf "Done copying data to USB drive %s\n " "${USB_drive}"
