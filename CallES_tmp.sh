#!/usr/bin/env bash

# This script calls the Python file ExternalScript, such that:
# 1. No capture stack is created;
# 2. No time lapse is created;
# 3. No reboot is performed;
# 4. BackupToUSB.sh is called;
# 5. My_Uploads file is called, if it exists;
# 6. The usual file set is uploaded to NM Server.
# Initially written by SGK, 03-Mar-2022. Byte Count = 871.

cd "${HOME}"/source/RMS
source "${HOME}"/vRMS/bin/activate

data_dir="${HOME}"/RMS_data
archive_dir="${data_dir}"/ArchivedFiles

fits_file=$(find "${data_dir}"/csv -name '*fits_counts.txt')
dir_str=$(tail -n 1 "${fits_file}" | grep -o '.*:')
dir=${dir_str::-1}   # remove the colon at end

env printf "fits_file: %s\n" "$fits_file"
env printf "dir_str: %s\n" "$dir_str"
env printf "dir: %s\n" "${dir}"

# Find newest directory in ArchivedFiles,
# then compare to fits_counts.txt last entry

target=$(ls -td "${archive_dir}"/*/ | head -1)

printf "target: %s\n" "$target"
#/home/pi/RMS_data/ArchivedFiles/US0002_20220228_012539_839995/

adir=${target: -30}
printf "adir: %s\n" "$adir"

adir=${adir:0:29}
printf "Archive directory: %s\n" "$adir"

station=${adir:0:6}
printf "Station: %s\n" "$station"

fcounts="$data_dir"/csv/"$station"_fits_counts.txt
printf "fits_counts file: %s\n" "$fcounts"

#US0002_20220303_333333_333333: 4087	1

if [[ "$adir" == "$dir" ]] ; then
    env printf "Same \n adir %s \n dir  %s \n" "${adir}" "${dir}"
    env printf " No need to run ES\n"
else
    env printf " running ES ...\n"
#python -m RMS.ExternalScript --directory "${adir}" --CreateTimeLapse false \
#       --CreateCaptureStack false --reboot false
fi

