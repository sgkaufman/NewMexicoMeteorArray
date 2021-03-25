#!/bin/bash

# NM_Server.sh will clear the NM_FILES_TO_UPLOAD.inf queue.
# The command line arg should be a directory under CapturedFiles or ArchivedFiles.
# The files in this directory will be added to the upload queue, but this will be
# a no-op if they've already been uploaded, and the queue will be cleared.

printf "\nNM_Server.sh, 24-Mar, 2021, byte count = 905 : Runs external script for NM file upload only.\n"
printf "The command line arg should be a directory under CapturedFiles or ArchivedFiles\n"

python -m RMS.ExternalScript --directory "$1" --log_script False --reboot False --CreateTimeLapse False --CreateCaptureStack False

_file="/home/pi/RMS_data/NM_FILES_TO_UPLOAD.inf"

if [ -s "$_file" ] 
then
	printf "\n $_file has is not empty."
	printf "\nThe NM file upload queue was not cleared.\n"
else
	printf "\n $_file is empty."
	printf "\nDone clearing the NM file upload queue.\n"
fi
