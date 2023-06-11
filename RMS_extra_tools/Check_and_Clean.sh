#!/bin/bash

# Check_and_Clean.sh
# This script requires a command line argument ("$1") containing 
# the full path to the CapturedFiles directory for a given night

capture_dir="$(dirname "$1")"
data_dir="$(dirname "$capture_dir")"
archive_dir="$data_dir"/ArchivedFiles
night_dir="$(basename "$1")"
station=${night_dir:0:6}
OUTFILE=$data_dir"/"${station}_"fits_counts.txt"

printf '\nCheck_and_Clean.sh, revised 11-Jun, 2023, 8829 bytes,'
printf ' was called with\nArg (directory) = %s \n' "$1"
printf 'This script writes results to %s \n' $OUTFILE
printf ' and can delete older files to make room for more capture directories\n\n'

Cleanup=1	# set to 0 to skip data cleanup at end of script

if [ ! -f "$OUTFILE" ]; then
    # file does not exist yet, so write top line of file:
    printf "Directory Name:         #fits_files #detections  Other Issues\n" > "$OUTFILE"
fi

total_fits=0
result=0
short_fall=0
secs_missed=0
min_missed=0

#echo data_dir:    $data_dir
#echo archive_dir: $archive_dir
#echo capture_dir: $capture_dir
#echo night_dir:   $night_dir
#echo station:     $station

# ____________________
# Sanity checks
if [[ ! -d $archive_dir ]] ; then
    echo "Directory $archive_dir does not exist! Exiting ..." >&2
    exit 1
fi

if [[ ! -d $capture_dir ]] ; then
    echo "Warning: Directory $capture_dir does not exist! Exiting ..." >&2
    exit 1
fi

if [[ ! -d $data_dir ]] ; then
    echo "Directory $data_dir does not exist! Exiting ..." >&2
    exit 1
fi
# End Sanity Checks

# Check that first argument to be sure it is an ArchivedFiles directory
if [[ $night_dir = '' || ! -d "${archive_dir}"/$night_dir ]] ; then
    printf 'Argument %s must specify a first-level sub-directory of %s\n' \
	"$night_dir" "${archive_dir}"
    exit 1
fi

# ____________________
# Calculate capture length in seconds using newest log file
capture_file=$(ls -Art $data_dir/logs/log_*.log | tail -n 1)
#echo Checking log file: $capture_file for capture duration

duration_line=$(grep -m1 Waiting $capture_file)
#echo log file line: $duration_line

hrs=$(echo "$duration_line" | awk '{print $10}')
seconds=`echo "$hrs*3600" | bc`
capture_len=${seconds:0:5}
#echo hours: $hrs, seconds: $seconds, rounded off seconds: $capture_len

# ____________________
# Collect information for the output file
# First, the number of FITS files captured

fits_count=$(find "$capture_dir/$night_dir"/*.fits -type f -printf x | wc -c)
printf '\nNumber of fits files in Capture directory: %d\n' "$fits_count"

# Use the total capture time to estimate the total number of fits files
total_fits=$(( capture_len * 100 / 1024 ))
result="$( awk -v x="$capture_len" 'BEGIN { print ( x / 10.24 ) }' )"
env printf "A capture lasting %d seconds, should create an estimated %d (%0.01f) fits files \n" \
	"$capture_len"  "$total_fits" "$result"

# Estimated total_fits is usually 4 more than number captured, so subtract 4 from total
total_fits=$(( total_fits - 4))
short_fall=$(( fits_count - total_fits ))
secs_missed=$(( short_fall * 1024 / 100 ))
min_missed="$( awk -v x=$secs_missed 'BEGIN { print ( x / 60 ) }' )"
env printf "We have a short fall of: %d fits, %d secs, %0.1f min\n\n" \
	$short_fall $secs_missed $min_missed

# ____________________
# Get the number of detections from the detected stack filename
stack=$(ls "$archive_dir/$night_dir"/*meteors.jpg)
# Anything such file found?
if [[ -n $stack ]] ; then
    # Yes! Find the number of meteors encoded in the file name
    detected=$(echo "$stack" | grep -Eo '[[:digit:]]+_meteors' | grep -Eo '[[:digit:]]+')
else
    # No such file found, there were no detections
    detected=0
fi

# ____________________
# Count the number of directories under CapturedFiles and ArchivedFiles
# The variable "id_string" extracts the station name and the date (in the
# form yyyymmdd) from the first positional parameter (the directory # name).
# It uses substring syntax (take the substring starting at position # 0 and
# extending 15 characters).
# The variable "id_string" holds the station name and date in a pattern.

id_string=${night_dir:0:15}
#printf "id_string: %s\n" "$id_string"

# CapturedFiles
pushd "$capture_dir" > /dev/null
echo 'Directories under CapturedFiles:'
ls -ld ./*"$id_string"*
captured_dirs=(./*"$id_string"*)
num_captured_dirs=${#captured_dirs[@]}
printf 'Directory count under CapturedFiles: %d\n' "$num_captured_dirs"
popd > /dev/null

# ArchivedFiles
pushd "$archive_dir" > /dev/null
echo 'Directories under ArchivedFiles:'
find . -maxdepth 1 -type d -name "*$id_string*"
num_archived_dirs=$(find . -maxdepth 1 -type d -name "*$id_string*" | wc -l)
printf 'Directory count under ArchivedFiles: %d\n' "$num_archived_dirs"
popd > /dev/null

# Write directory name to the ouput file
printf "%s: " "$night_dir" >> "$OUTFILE"

if [[ $fits_count -eq 0 ]]; then
   printf "NO FITS FILES! " >> "$OUTFILE"
fi

if [[ $num_captured_dirs -eq $num_archived_dirs ]] ; then
   if [[ $num_archived_dirs -eq 1 ]] ; then
	printf "%d\t%d" >> "$OUTFILE" \
	"$fits_count" "$detected"

	# echo any short fall in fits files
	if [[ $short_fall -lt 0 ]] ; then
	   printf "\t%d fits %0.1f min" >> "$OUTFILE" \
	   "$short_fall" "$min_missed"
	fi

   else
	printf "%d\t%d\t Arch_Dir: %d" >> "$OUTFILE" \
	"$fits_count" "$detected" "$num_archived_dirs"
   fi
else
    printf "%d\t%d\tCap_Dir: %d\tArch_Dir: %d" >> "$OUTFILE" \
	"$fits_count" "$detected" "$num_captured_dirs" "$num_archived_dirs"
fi

# Write a warning if there is no photometry plot
if ! compgen -G "${archive_dir}/$night_dir/*_calib_report_photometry.png" > /dev/null ; then
   if [[ $detected -lt 3 ]] ; then
	printf "  No Photometry, Clouded out?" >> "$OUTFILE"
   else
	printf "  No Photometry!" >> "$OUTFILE"
   fi
fi

# ____________________
# Check the total number of directories in the CapturedFiles directory,
#  not just the number matching the date, warn if there is only one found
pushd "$capture_dir" > /dev/null
captured=(./*"$station"*)
total_captured=${#captured[@]}
printf "Total_captured (number of directories under CapturedFiles): %d\n" \
	"$total_captured"
popd > /dev/null

if [[ $total_captured -eq 1 ]]; then
    total_space=$(df --output=size -h "$PWD" | sed '1d;s/[^0-9]//g')
    free_space=$(df --output=avail -h "$PWD" | sed '1d;s/[^0-9]//g')
    printf " Only one Capture Directory! %d GB free / %d GB total" \
	"$free_space" "$total_space" >> "$OUTFILE"
fi

printf "\n" >> "$OUTFILE"

printf "Fits file count and number of detections saved to: %s\n\n" "$OUTFILE"

# ____________________________________________________________________
# This section of the script can be used to clean up old files to free
# up space on the storage drive for more CapturedFiles directories
# var Cleanup is set above on line 19

# set variables adirs, cdirs, and bz2 to 0 to skip cleanups
adirs=10	# delete older ArchivedFiles directories
cdirs=10	# delete older CapturedFiles directories
bz2=10		# delete older tar.bz2 archives
logs=21		# delete log files older than this number of days

# Define function clean_dir, with arguments:
# 1. directory to clean
# 2. number to keep
# Clean_dir uses strictly lexicographic ordering, useful
# for CapturedFiles and ArchivedFiles.
# Not yet used for .bz2 files,
# which would require an extra arg to search files instead of directories.
# Not used for logs, where different log file names are common.

function clean_dir()
{
    #printf "clean_dir called with arg1 %s and arg2 %d\n" $1 $2

    # enclosing parentheses make the result an array
    dir_array=($(find "$1" -maxdepth 1 -type d -name "${station}*" | sort -r))

    dir_len=${#dir_array[@]}
    #printf "Number directories under %s: %d\n" $1 ${dir_len}

    for ((i=0; i<dir_len; i++)); do
	#printf "%d: %s\n" $i ${dir_array[i]}
	if [[ $i -gt $2-1 ]]; then
	    #printf "Removing directory %s\n" ${dir_array[i]}
	    rm -f -r ${dir_array[i]}
	else
	    #printf "Retaining directory %s\n" ${dir_array[i]}
	fi
    done
}

if [ $Cleanup -gt 0 ]; then
   printf "Deleting old directories and files\n"

   if [ $adirs -gt 0 ]; then
       printf "Deleting ArchivedFiles directories more than %s days old\n" "${adirs}"
       clean_dir "${archive_dir}" $adirs
    fi

   if [ $cdirs -gt 0 ]; then
       printf "Deleting CapturedFiles directories more than %s days old\n" "${cdirs}"
       clean_dir "${capture_dir}" $cdirs 
   fi

   cd $archive_dir
   if [ $bz2 -gt 0 ]; then
      printf "Deleting tar.bz2 files more than %s days old\n" "${bz2}"
      bz2=$((bz2-1))
      find -type f -mtime +$bz2 -delete;
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
