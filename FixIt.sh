#!/bin/bash
# FixIt.sh	see echo line below for date of last update
# Combine reprocessing & external script calls
# typical call is:	./FixIt.sh US0008_20191002_011553_128819
#
# .FixIt.sh can take three arguments, all of which are 1 for Yes and 0 for No
# .FixIt.sh <directory name> arg2 arg3 arg4 
#   arg1 <directory name>
#   arg2 reboot, where 0 overrides normal reboot
#   arg3 timelapse, where 0 overrrides normal timelapse mp4 file creation
#   arg4 reprocess data in ArchiveFilesReprocessed, where creation
#	of timelapse mp4 using captured files directory is optional
#
# so for a normal run:	./FixIt.sh <directory name>
#  no reboot: 		./FixIt.sh <directory name> 0
#	since creation of timelapse is the default behavior, a mp4 will
#	be created, resulting in the same behavior as the next example:
#  no reboot, mp4	./FixIt.sh <directory name> 0 1
#  reboot, no mp4: 	./FixIt.sh <directory name> 1 0
#  no reboot, no mp4: 	./FixIt.sh <directory name> 0 0
#  run on ArchivedFilesReprocessed:	./FixIt.sh <directory name> 0/1 0/1 1
#					arg 2: 0 or 1
#					arg 3: 0 or 1
#					arg 4: 1 or other, only testing to see if arg4 exists
# A typical run on ArchiveFilesReprocessed data, no reboot, and no mp4 wouild be:
#			./FixIt.sh <directory name> 0 0 1

cd /home/pi/source/RMS
echo FixIt.sh, 24-Feb, 2021, byte count = 2414 : Combining reprocess and external script calls...
case $# in
    "4")
         echo "Reprocessing data in ArchivedFilesReprocessed $1, with reboot=$2, and create mp4=$3"
         python -m RMS.Reprocess ~/RMS_data/ArchivedFilesReprocessed/"$1"
         python -m RMS.ExternalScript --directory "$1" --reboot "$2" --CreateTimeLapse "$3"
         ;;
    "3")
         echo "Reprocessing data in CapturedFiles $1, with reboot=$2, and create mp4=$3"
         python -m RMS.Reprocess ~/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1" --reboot "$2" --CreateTimeLapse "$3"
         ;;
    "2")
         echo "Reprocessing data in CapturedFiles $1, with reboot=$2, after mp4 created"
         python -m RMS.Reprocess ~/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1" --reboot "$2"
         ;;
    *)
         echo "Reprocessing data in CapturedFiles $1,  with mp4 created, then reboot"
         python -m RMS.Reprocess ~/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1"
         ;;
esac 