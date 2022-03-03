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
# host=$(hostname)
fits_file=$(find "${data_dir}"/csv -name *fits_counts.txt)
dir_str=$(tail -n 1 "${fits_file}" | grep -o '.*:')
dir="${dir_str::-1}"   # remove the colon at end

env printf "fits_file: %s\n" "$fits_file"
env printf "dir_str: %s\n" "$dir_str"
env printf "dir: %s\n" "${dir}"

python -m RMS.ExternalScript --directory "${dir}" --CreateTimeLapse false \
       --CreateCaptureStack false --reboot false
