#!/usr/bin/env bash

# This script calls the Python file ExternalScript, such that:
# 1. No capture stack is created;
# 2. No time lapse is created;
# 3. No reboot is performed;
# 4. BackupToUSB.sh is called;
# 5. My_Uploads file is called, if it exists;
# 6. The usual file set is uploaded to NM Server.
# Initially written by SGK, 02-Mar-2022. Byte Count = 820.

cd "${HOME}"/source/RMS
source "${HOME}"/vRMS/bin/activate

data_dir="${HOME}"/RMS_data
host=$(hostname)
date_str=$(date +%Y%m%d)
dir=$(find "${data_dir}"/ArchivedFiles/ -type d | grep -o "${host}"_"${date_str}"[_0-9]*)

env printf "hostname: %s\n" "$host"
env printf "date_str: %s\n" "$date_str"
env printf "dir: %s\n" "${dir}"

python -m RMS.ExternalScript --directory "${dir}" --CreateTimeLapse false \
       --CreateCaptureStack false --reboot false
