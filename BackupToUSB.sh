#!/bin/bash

# BackupToUSB.sh
# Takes one arg, which is the full path and filename for the ArchivedFiles data
# directory for the night you want to backup.
# Assumes that the destination has directories bz2, csv, CapStack, and TimeLapse
# Argument1: ArchivedFiles directory name

printf "BackupToUSB.sh 28-Mar, 2024, byte count ~1710 : backs up data to USB drive,\n"

# set station specific USB drive designation
USB_drive="/media/pi/US00012_BK"

archive_dir="$(dirname "$1")"
data_dir="$(dirname "$archive_dir")"
night_dir="$(basename "$1")"
station=${night_dir:0:6}

# Let's check that first argument. Must be in the ArchivedFiles directory.
if [[ $night_dir = '' || ! -d "${archive_dir}"/$night_dir ]] ;
then
    printf 'Argument %s must specify a first-level sub-directory of %s\n' \
        "$night_dir" ${archive_dir} 
    exit 1
fi

# copy fits_count.txt
target="${data_dir}/csv/${station}_fits_counts.txt"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy .csv
target="${data_dir}/csv/$night_dir.csv"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy radiants.txt
target="${data_dir}/csv/"$night_dir"_radiants.txt"
printf "Copying %s\n" "${target}"
cp "${target}" "${USB_drive}/csv"

# copy or move tar.bz2
target="${archive_dir}/"$night_dir"_detected.tar.bz2"
if [[ -s "${data_dir}"/FILES_TO_UPLOAD.inf ]] ;
then
    # not empty
    printf "Copying %s...\n" "${target}"
    cp "${target}" "${USB_drive}/bz2"
else
   #  yes, is empty
   printf "Moving %s...\n" "${target}"
   mv "${target}" "${USB_drive}/bz2"
fi

# ____________________________________________________________________

printf "Done copying data to USB drive %s\n\n " "${USB_drive}"

