#!/bin/bash

# BackupToUSB.sh
# Takes one arg, which is the full path and filename for the ArchivedFiles data
# directory for the night you want to backup.
# Assumes that the destination has directories bz2, csv, CapStack, and TimeLapse
# Argument1: ArchivedFiles directory name
# If Cleanup=1, will also delete
#	ArchivedFiles directories older than $adirs days
#	CapturedFiles directories older than $cdirs days
#	tar.bz2 files older than  $bz2 days
#	log files older than $logs days

printf "BackupToUSB.sh 24-Mar, 2023, byte count ~3415 : backs up data to USB drive,\n"
printf " and can also delete old data\n"

# set station specific USB drive designation
USB_drive="/media/usbdrive/"

Cleanup=1

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
# This section of the script can be used to clean up old files to free
# up space on the storage drive for more CapturedFiles directories
# var Cleanup is set above on line 19

# set variables adirs, cdirs, and bz2 to 0 to skip cleanups
adirs=7   # delete older ArchivedFiles directories
cdirs=10  # delete older CapturedFiles directories
bz2=7     # delete older tar.bz2 archives
logs=21   # delete log files older than this number of days

if [ $Cleanup -gt 0 ]; then
   printf "Deleting old directories and files\n"

   cd $archive_dir
   if [ $adirs -gt 0 ]; then
      printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
      adirs=$((adirs-1))
      find -mtime +$adirs -type d | xargs rm -f -r
   fi

   if [ $bz2 -gt 0 ]; then
      printf "Deleting tar.bz2 files more than %s days old\n" "${bz2}"
      bz2=$((bz2-1))
      find -type f -mtime +$bz2 -delete;
   fi

   if [ $cdirs -gt 0 ]; then
      cd ../CapturedFiles
      printf "Deleting CapturedFiles directories more than %s days old\n" "${cdirs}"
      cdirs=$((cdirs-1))
      find -mtime +$cdirs -type d | xargs rm -f -r
   fi

  if [ $logs -gt 0 ]; then
      cd $data_dir/logs
      printf "Deleting log files more than %s days old\n" "${logs}"
      logs=$((logs-1))
      find -type f -mtime +$logs -delete;
   fi

   printf "Done deleting old data\n "
fi
# ____________________________________________________________________

printf "Done copying data to USB drive %s and deleting old data\n\n " "${USB_drive}"
