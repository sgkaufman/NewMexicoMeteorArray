#!/bin/bash

# BackupToUSB.sh
# Takes one arg, which is the full path and filename for the ArchivedFiles data
# directory for the night you want to backup.
# Assumes that the destination has directories bz2, csv, CapStack, and TimeLapse
# Argument1: ArchivedFiles directory name
# Can also clean out ArchivedFiles directories that are older than $adirs days
#  and can clean out CapturedFiles directories that are older than $cdirs days
#  if $adirs is greater than zero, will also delete log files older than 21 days

printf "BackupToUSB.sh 21-Sep, 2022, byte count ~2986 : backs up data to thumb drive\n"

# set adirs to zero to skip deleting older ArchivedFiles directories
adirs=10
adir=$((adirs-1))

# set cdirs to zero to skip deleting older CapturedFiles directories
cdirs=10
cdir=$((cdirs-1))

# set station specific USB drive designation
USB_drive="/media/pi/US00012_BK"

archive_dir="$(dirname "$1")"
data_dir="$(dirname "$archive_dir")"
capture_dir="$data_dir"/CapturedFiles
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

# move TimeLapse.mp4, modified to work with IStream
target="${data_dir}/*.mp4"
printf "Moving %s\n" "${target}"
cd ${data_dir}
for f in *.mp4; do
    mv "$f" "${USB_drive}/TimeLapse"
done

# move Captured_Stack.jpg
target="${data_dir}/*_captured.jpg"
printf "Moving %s\n" "${target}"
cd ${data_dir}
for f in *_captured.jpg; do
    mv "$f" "${USB_drive}/CapStack"
done

if [[ $adirs -gt 0 ]] ;
then
    cd ${data_dir}/ArchivedFiles
    printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
    find -mtime +$adir -type d | xargs rm -f -r
    cd ../logs
    printf "Deleting log files more than 31 days old\n"
    find *.log -type f -mtime +30 -delete;
fi

if [[ $cdirs -gt 0 ]] ;
then
    cd ${data_dir}/CapturedFiles
    printf "Deleting CapturedFiles directories more than %s days old\n" "${cdirs}"
    find -mtime +$cdir -type d | xargs rm -f -r
fi

printf "Done copying data to USB drive %s\n\n " "${USB_drive}"
