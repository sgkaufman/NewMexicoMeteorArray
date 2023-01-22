#!/usr/bin/env bash

# This script calls the Python file ExternalScript, such that:
# 1. No capture stack is created;
# 2. No time lapse is created;
# 3. No reboot is performed;
# 4. BackupToUSB.sh is called;
# 5. My_Uploads file is called, if it exists;
# 6. The usual file set is uploaded to NM Server.
# Initially written by SGK
# 05-Mar-2022. Byte Count = 1323

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

adir=${target: -30}
adir=${adir:0:29}
printf "Archive directory: %s\n" "$adir"

if [[ "$adir" == "$dir" ]] ; then
    env printf "Same \n adir %s \n dir  %s \n" "${adir}" "${dir}"
    env printf " No need to run ES\n"
else
    env printf " running ES ...\n"
    python -m RMS.ExternalScript --directory "${adir}" --CreateTimeLapse true \
	   --CreateCaptureStack true --reboot false
fi
