#!/bin/bash

# Clean.sh, takes one argument
# Argument1: path to data directory for previous night
# For exaple:
# /home/pi/RMS_data/US0001/ArchivedFiles/US0001_20240127_005520_080575
#
# Note: adirs must be greater than cdirs+2 to avoid reprocessing errors
# Deletes:
#  ArchivedFiles directories numbering greather than $adirs
#  CapturedFiles directories numbering greather than $cdirs
#  log files older than $logs days
#  tar.bz2 files older than $bz2 days, but only if FILES_TO_UPLOAD.inf is empty

printf "Clean.sh 13-Mar, 2024, 3650 bytes, deletes old data directories, tar.bz2 and log files\n"

debug=0   # control whether to echo key variables
adirs=10  # delete older ArchivedFiles directories
cdirs=7   # delete older CapturedFiles directories
bz2=10    # delete older tar.bz2 archives
logs=21   # delete log files older than this number of days

declare -a dir_array

if [[ $adirs -lt $((cdirs+3)) ]]; then
adirs=$((cdirs+3))
printf "Retaining three more ($adirs) Archived directories than Captured directories ($cdirs)\n"
fi

archive_dir="$(dirname "$1")"
data_dir="$(dirname "$archive_dir")"
night_dir="$(basename "$1")"
station=${night_dir:0:6}

if [[ $debug -gt 0 ]]; then
    echo arg1        = $1
    echo archive_dir = $archive_dir
    echo data_dir    = $data_dir
    echo station     = $station
fi

# Let's check that first argument. Must be in the ArchivedFiles directory.
if [[ $night_dir = '' || ! -d "${archive_dir}"/$night_dir ]] ;
then
    printf 'Argument %s must specify a first-level sub-directory of %s\n' \
        "$night_dir" ${archive_dir} 
    exit 1
fi

#----------
printf "\nDeleting old ArchivedFiles directories, "
dir_len=$(find $data_dir/ArchivedFiles -maxdepth 1 -type d -name $station* | wc -l)
printf "starting with %d directories " ${dir_len}
if [[ $dir_len -gt $adirs ]]; then
    printf "and keeping %d\n" ${adirs}
else
    printf "and keeping all of them\n"
fi
dir_array=($(find $data_dir/ArchivedFiles -maxdepth 1 -type d -name $station* | sort -r))

for ((i=0; i<dir_len; i++)); do
    #printf "%d: %s\n" $i ${dir_array[i]}
    if [[ $i -gt $adirs-1 ]]; then
	printf "Removing %s\n" ${dir_array[i]}
	rm -rf ${dir_array[i]}
    else
	if [[ $debug -gt 0 ]]; then
	    printf "Keeping %s\n" ${dir_array[i]}
	fi
    fi
done

#----------
printf "Deleting old CapturedFiles directories, "
dir_len=$(find $data_dir/CapturedFiles -maxdepth 1 -type d -name $station* | wc -l)
printf "starting with %d directories " ${dir_len}
if [[ $dir_len -gt $cdirs ]]; then
    printf "and keeping %d\n" ${cdirs}
else
    printf "and keeping all of them\n"
fi

dir_array=($(find $data_dir/CapturedFiles -maxdepth 1 -type d -name $station* | sort -r))
for ((i=0; i<dir_len; i++)); do
    #printf "%d: %s\n" $i ${dir_array[i]}
    if [[ $i -gt $cdirs-1 ]]; then
	printf "Removing %s\n" ${dir_array[i]}
	rm -rf ${dir_array[i]}
    else
	if [[ $debug -gt 0 ]]; then
	    printf "Keeping %s\n" ${dir_array[i]}
	fi
    fi
done

#----------
if [ $logs -gt 0 ]; then
   cd $data_dir/logs
   printf "Deleting log files more than %s days old\n" "${logs}"
   logs=$((logs-1))
   find -type f -mtime +$logs -delete;
fi

#----------
if [ $bz2 -gt 0 ]; then
   if [[ -s "${data_dir}"/FILES_TO_UPLOAD.inf ]] ;
   then
      # not empty
      printf "FILES_TO_UPLOAD.inf is not empty!, not deleting any tar.bz2 files\n"
   else
      #  yes, is empty
      cd $data_dir/ArchivedFiles
      printf "Deleting tar.bz2 files more than %s days old\n" "${bz2}"
      bz2=$((bz2-1))
      find -type f -mtime +$bz2 -delete;
   fi
fi

# ____________________________________________________________________

printf "Done deleting old data\n\n"

