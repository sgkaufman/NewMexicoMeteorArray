#!/bin/bash
# FixIt.sh
# Combine reprocessing & external script calls
#  a typical call is:	./FixIt.sh US0008_20191002_011553_128819
#
# .FixIt.sh can take five arguments, four of which are 1/0 for Yes/No, or True/False
# .FixIt.sh <directory name> arg2 arg3 arg4 arg5 
#
#   arg1 <directory name>
#   arg2 reboot, where 0/False overrides normal reboot
#   arg3 TimeLapse, where 0/False overrrides normal TimeLapse mp4 file creation
#   arg4 CapStack, where 0/False overrrides normal CapStack file creation
#   arg5 reprocess data in ArchiveFilesReprocessed, where creation
#	of TimeLapse mp4 using captured files directory and capstck are optional
#
# so for a normal run:	./FixIt.sh <directory name>
#  no reboot: 		./FixIt.sh <directory name> 0
#	since creation of TimeLapse and capt stack are often default behavior,
#	mp4 and CapStack.jpg will be created, resulting in the same behavior 
#	as the next example:
#  no reboot, mp4	./FixIt.sh <directory name> 0 1
#   or
#  no reboot, mp4, CapStack	./FixIt.sh <directory name> 0 1 1
#  reboot, no mp4: 	./FixIt.sh <directory name> 1 0
#  no reboot, no mp4: 	./FixIt.sh <directory name> 0 0
#  reboot, mp4, CapStack: 	./FixIt.sh <directory name> 1 1 1
#  run on ArchivedFilesReprocessed:	./FixIt.sh <directory name> 0/1 0/1 0/1 1
#					arg 2: 0 or 1
#					arg 3: 0 or 1
#					arg 4: 0 or 1
#					arg 5: 1 or other, only testing to see if arg4 exists
# A run on ArchiveFilesReprocessed data, no reboot, no mp4, no CapStack wouild be:
#			./FixIt.sh <directory name> 0 0 0 1

cd "$HOME"/source/RMS
printf "\nFixIt.sh, 09-Jul, 2021, byte count 3518 : Combining reprocess and external script calls...\n"

if [ $# -eq 0 ] ; then 
   printf "No first argument given, exiting now\n"
   exit 1
   fi

if [ ! -d "$HOME"/RMS_data/CapturedFiles/"$1" ] && [ ! -d "$HOME"/RMS_data/ArchivedFilesReprocessed/"$1" ] ; then
   printf "First argument: %s  must be a valid directory to reprocess\n" "$1"
   exit 1
   fi

case $# in
    "5")
         printf "Reprocessing data in ArchivedFilesReprocessed %s, with reboot=%s, create mp4=%s, and create CapStack=%s\n" "$1" "$2" "$3" "$4"
         python -m RMS.Reprocess "$HOME"/RMS_data/ArchivedFilesReprocessed/"$1"
         python -m RMS.ExternalScript --directory "$1" --log_script 0 --reboot "$2" --CreateTimeLapse "$3" --CreateCaptureStack "$4"
         ;;
    "4")
         printf "Reprocessing data in CapturedFiles %s, with reboot=%s, create mp4=%s, and create CapStack=%s\n" "$1" "$2" "$3" "$4"
         python -m RMS.Reprocess "$HOME"/RMS_data/ArchivedFilesReprocessed/"$1"
         python -m RMS.ExternalScript --directory "$1" --log_script 0 --reboot "$2" --CreateTimeLapse "$3"--CreateCaptureStack "$4"
         ;;
    "3")
         printf "Reprocessing data in CapturedFiles %s, with reboot=%s, and create mp4=%s\n" "$1" "$2" "$3"
         python -m RMS.Reprocess "$HOME"/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1" --log_script 0 --reboot "$2" --CreateTimeLapse "$3"
         ;;
    "2")
         printf "Reprocessing data in CapturedFiles %s, with reboot=%s\n" "$1" "$2"
         python -m RMS.Reprocess "$HOME"/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1" --log_script 0 --reboot "$2"
         ;;
    *)
         printf "Reprocessing data in CapturedFiles %s, with default reboot\n" "$1"
         python -m RMS.Reprocess "$HOME"/RMS_data/CapturedFiles/"$1"
         python -m RMS.ExternalScript --directory "$1" --log_script 0
         ;;
esac
