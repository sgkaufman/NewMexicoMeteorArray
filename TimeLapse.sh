#!/bin/bash

# TimeLapse.sh
# Create timelapse file, then move it, .csv, & *radiants.txt files
#  so they can be easily located
# Argument1 ($1): Full path to ArchivedFiles directory
# Argument2 ($2): False, 0 or No will skip creating TimeLapse.mp4
# Argument3 ($3): False, 0 or No will skip creating stack of CapturedFiles
# Default script action is to create TimeLapse.mp4 and Capture stack

printf 'TimeLapse.sh, revised 11-May, 2023, byte count 11002, '
printf 'was called with\nArg 1 = %s, arg 2 = %s, arg 3 = %s\n\n' "$1" "$2" "$3"
printf 'TimeLapse.sh copies radiants.txt, and .csv files to RMS_data/csv/, then creates a\n'
printf 'TimeLapse.mp4 file, and stack of all captured images, which are moved to RMS_data.\n'
printf 'You can suppress creation of the mp4 and captured stack by specifying  False, 0 or\n'
printf 'No  as the second argument for mp4 and third argument for captured stack.\n'
printf 'TimeLapse.mp4, Radiants, Stack and Capture jpg files can optionally be copied to \n'
printf 'My_Uploads by setting My_Uploads=1 in this script file. You can change the default\n'
printf 'actions of this script by editing the values for TimeLapse and CapStack.\n\n'

# Use the following three vars to control script default actions:
#  0 for no, 1 for yes
TimeLapse=0
CapStack=0
My_Uploads=0
iStream=0

# Let's check that second argument
if [[ "$2" = "False" || "$2" = "0" || "$2" = "No" ]] ; then
    TimeLapse=0
fi

# Let's check that third argument
if [[ "$3" = "False" || "$3" = "0" || "$3" = "No" ]] ; then
    CapStack=0
fi

archive_dir="$(dirname "$1")"
data_dir="$(dirname "$archive_dir")"
capture_dir="$data_dir"/CapturedFiles
night_dir="$(basename "$1")"
station=${night_dir:0:6}

echo data_dir:    $data_dir
echo archive_dir: $archive_dir
echo capture_dir: $capture_dir
echo night_dir:   $night_dir
echo station:     $station

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

# Let's check that first argument to be sure it is an ArchivedFiles directory
if [[ $night_dir = '' || ! -d "${archive_dir}"/$night_dir ]] ; then
    printf 'Argument %s must specify a first-level sub-directory of %s\n' \
	"$night_dir" "${archive_dir}"
    exit 1
fi

OUTFILE=$data_dir"/csv/"${station}_"fits_counts.txt"
echo fits_counts.txt file is $OUTFILE

# Get the environment for Python set up, and move to the right directory
source "$HOME"/vRMS/bin/activate
cd "$HOME"/source/RMS/

if [[ ${My_Uploads} = 1 ]]; then
    printf 'Cleaning out older files in My_Uploads\n'
    rm "$HOME"/RMS_data/My_Uploads/*
fi


# Create the timelapse
if [[ $TimeLapse = 0 ]] ; then
    printf "\nSkipping creation of Timelapse mp4 for directory %s/%s\n" \
	"${capture_dir}" "$night_dir"
else
    if [[ -d "${capture_dir}/$night_dir" ]] ; then
        # When run after iStream we want to recycle their mp4 file
        if [[ $iStream -ne 1 ]] ; then
            printf '%s\n' "Creating Timelapse of directory ${capture_dir}/$night_dir"
	    python -m Utils.GenerateTimelapse "$capture_dir"/"$night_dir"
	fi
	# Move the timelapse up to the RMS_data directory
	printf 'Moving Timelapse to RMS_data\n'
	cd -- "$capture_dir"/"$night_dir"
	if [[ ${My_Uploads} = 1 ]]; then
	    printf 'Copying TimeLapse.mp4 to My_Uploads\n'
	    cp ./*.mp4 "$HOME"/RMS_data/My_Uploads/TimeLapse.mp4
	fi
	mv -v -- ./*.mp4 ${data_dir}
    else
	printf 'Directory %s does not exist. TimeLapse will not be created.\n' \
	    "${capture_dir}/$night_dir"
    fi
fi


# When run after iStream, their CapStack is a converted BMP, which is larger
#  than jpg created from scratch, so we make ours anyway? (costs ~12 minutes or less)

# Create a stack of the capture directory
if [[ $CapStack = 0 ]] ; then
    printf "\nSkipping creation of stack of CapturedFiles for directory %s/%s\n" \
	"${capture_dir}" "$night_dir"
else
    if [[ -d "${capture_dir}/$night_dir" ]] ; then
	# save capture stack
	cd -- "$capture_dir"/"$night_dir"
	d_stack=$(ls ./*stack*_meteors.jpg)
	mv ./*_meteors.jpg m

	cd "$HOME"/source/RMS/
	printf "Creating a stack of the capture directory: %s\n" "$night_dir"
	python -m Utils.StackFFs "$capture_dir"/"$night_dir" jpg -s -x \
		> /dev/null

	cd -- "$capture_dir"/"$night_dir"
	c_stack=$(ls ./*stack*_meteors.jpg)
	c_stack=${c_stack/meteors/captured}
	mv ./*_meteors.jpg "$c_stack"

	# restore detction stack
	mv m "$d_stack"

	# Check to see if this capture stack should be moved
	if [[ ${My_Uploads} = 1 ]] ; then
	    printf 'Copying Captured stack to My_Uploads\n'
	    cp ./*captured.jpg "$data_dir"/RMS_data/My_Uploads/Captured.jpg
	fi
	cp ./*captured.jpg "${data_dir}"
	cp ./*captured.jpg "${archive_dir}/$night_dir"

    else
	printf 'Directory %s does not exist. Captured stack will not be created.\n' \
	    "${capture_dir}/$night_dir"
    fi
fi

cd -- $archive_dir/"$night_dir"
# Check for existence of the "RMS_data/csv directory
if [[ ! -d "${data_dir}"/csv ]] ; then
    printf 'Directory %s does not exist\n' "${data_dir}/csv"
    if [[ -f "${data_dir}"/csv ]] ; then
	# There is no directory called csv under RMS_data but there is a file
	printf 'Moving file %s to file %s\n' "${data_dir}"/csv "${data_dir}"/csv-temp
	mv "${data_dir}"/csv "${data_dir}"/csv-temp
    fi
    # No regular file with the name exists either
    printf 'Creating directory %s\n' "${data_dir}"/csv
    mkdir "${data_dir}"/csv
    echo 'Number of fits files in Capture directory' > "$OUTFILE"
else
    # There already is a directory "$data_dir"/RMS_data/csv
    printf '\nDirectory %s already exists\n' "${data_dir}/csv"
fi

# Copy the csv file up to the RMS_data/csv directory
printf 'Copying csv file to directory %s\n' "${data_dir}/csv"
cp -v -- ./*.csv "${data_dir}/csv"

# Copy the radiants.txt file up to the RMS_data/csv directory
printf 'Copying radiants.txt file to directory %s\n' "${data_dir}/csv"
cp -v -- ./*radiants.txt "${data_dir}/csv"

if [[ ${My_Uploads} = 1 ]]; then
    printf 'Copying Radiants.jpg to My_Uploads\n'
    cp ./*radiants.png "$HOME"/RMS_data/My_Uploads/Radiants.png
fi

# Collect information for output to csv file
# First, the number of FITS files

fits_count=$(find "$capture_dir/$night_dir"/*.fits -type f -printf x | wc -c)
printf "\n"
printf 'Number of fits files in Capture directory: %d\n' "$fits_count"

# Next, find the total capture time and estimate the number of fits files
capture_len=0
total_fits=0
result=0
short_fall=0
secs_missed=0
min_missed=0

# Find the latest CaptureTimes file in the log directory
capture_file=$(ls -t "$HOME"/RMS_data/logs/"CaptureTimes"* | sed -n 1p)

# Read the start time and capture duration from the file
{
    read -r start_date
    capture_len=$(grep -Eo '^[0-9]+' -)
} < "$capture_file"

total_fits=$(( capture_len * 100 / 1024 ))
result="$( awk -v x="$capture_len" 'BEGIN { print ( x / 10.24 ) }' )"
env printf "A capture lasting %d seconds, should create an estimated %d (%0.01f) fits files \n" \
	"$capture_len"  "$total_fits" "$result"

# estimated total_fits is typically 4 more than observed, so we subtract 4 from total
total_fits=$(( total_fits - 4))
short_fall=$(( fits_count - total_fits ))
secs_missed=$(( short_fall * 1024 / 100 ))
min_missed="$( awk -v x=$secs_missed 'BEGIN { print ( x / 60 ) }' )"
env printf "We have a short fall of: %d fits, %d secs, %0.1f min\n\n" \
	$short_fall $secs_missed $min_missed
# Done finding the total capture time and the estimated number of fits files


# Find the number of detections in the stack file
stack=$(ls "$archive_dir/$night_dir"/*meteors.jpg)
# Anything such file found?
if [[ -n $stack ]] ; then
    # Yes! Find the number of meteors encoded in the file name
    detected=$(echo "$stack" | grep -Eo '[[:digit:]]+_meteors' | grep -Eo '[[:digit:]]+')
else
    # No such file found, there were no detections
    detected=0
fi

if [[ ${My_Uploads} = 1 ]]; then
    printf 'Copying Detected Stack.jpg to My_Uploads\n'
    cp ./*meteors.jpg "$HOME"/RMS_data/My_Uploads/Stack.jpg
fi

# Count the number of directories under CapturedFiles and ArchivedFiles
# The variable "id_string" extracts the station name and the date (in the 
# form yyyymmdd) from the first positional parameter (the directory # name). 
# It uses substring syntax (take the substring starting at position # 0 and 
# extending 15 characters).
# The variable "id_string" holds the station name and date in a pattern.

id_string=${night_dir:0:15}
printf "id_string: %s\n" "$id_string"

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

# Write it out to the file in the csv directory

printf "%s: " "$night_dir" >> "$OUTFILE"

if [[ $fits_count -eq 0 ]]; then
   printf "NO FITS FILES! " >> "$OUTFILE"
fi

if [[ $num_captured_dirs -eq $num_archived_dirs ]] ; then
   if [[ $num_archived_dirs -eq 1 ]] ; then
	printf "%d\t%d" >> "$OUTFILE" \
	"$fits_count" "$detected"

	# echo the short fall in fits files if large enough
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

if ! compgen -G "${archive_dir}/$night_dir/*_calib_report_photometry.png" > /dev/null ; then
   if [[ $detected -lt 3 ]] ; then
	printf "  No Photometry, Clouded out?" >> "$OUTFILE"
   else
	printf "  No Photometry!" >> "$OUTFILE"
   fi
fi


# Now check for the TOTAL number of directories in the CapturedFiles 
# directory, not just the number matching the date
pushd "$capture_dir" > /dev/null
captured=(./*"$station"*)
total_captured=${#captured[@]}
printf "total_captured (number of directories under CapturedFiles): %d\n" \
	"$total_captured"
popd > /dev/null

if [[ $total_captured -eq 1 ]]; then
    total_space=$(df --output=size -h "$PWD" | sed '1d;s/[^0-9]//g')
    free_space=$(df --output=avail -h "$PWD" | sed '1d;s/[^0-9]//g')
    printf " Only one Capture Directory! %d GB free / %d GB total" \
	"$free_space" "$total_space" >> "$OUTFILE"
fi

printf "\n" >> "$OUTFILE"

printf "fits file count and number of detections saved to: %s\n\n" "$OUTFILE"
