# New Mexico Meteor Array 21-Aug, 2021
Files for the New Mexico Meteor Array sub-network of the Global Meteor Network

# Functions implemented
## Post-processing for the New Mexico Meteor Array
- ExternalScript.py (Uploads some files to NM Server, calls the following two)
- TimeLapse.sh (creates TimeLapse mp4 movie, CaptureStack, and statistical diagnostic information)
- BackupToUSB.sh (Backs up some nightly date to an attached USB flash drive)

## Recording Watchdog. This watchdog restarts RMS if capture stops during the night.
- StartCaptureWatchdog.sh
- RecordWatchdog.sh
- WriteCapture.py

## Utilities
- Backup.sh
- CamSet.sh
- Chk_Website.sh
- FixIt.sh
- FlushNMqueue.sh
- FlushNMqueue.py
- move_to_RMS.sh
- RMS_Restart.sh
- Turn_Features_On_Off.txt
- Update.sh
- WriteCapture.sh
- WriteCaptureEphem.py
_____

Backup.sh	 	7/9/2021 11:37 AM  1015
	Creates reference copy of key microSD card files

BackupToUSB.sh		 8/17/2021  2:13 PM  1626
	Backup data every morning to thumb drive, called by ExternalScript.py

CamSet.sh	 	4/15/2021 11:11 AM  1239
	Utility for switching camera between nighttime & daytime modes

Chk_Website.sh	 	7/9/2021 11:39 AM  1209
	Status monitor Pete runs on US0002

ExternalScript.py	 8/21/2021  8:37 AM  12925
	NMMA ExternalScript.py
	If My_Uploads.sh is found will be used to copy station files 
	to a station owner's web site. Calls TimeLapse.sh, and My_Uploads.sh

FixIt.sh		 7/9/2021 11:40 AM  3518
	Utility for processing missing data: runs a reprocess job followed by
	ExternalScript.py

FlushNMqueue.py		 8/8/2021 10:11 AM  1452
	Utility for uploading to NM Server if needed

FlushNMqueue.sh		 7/9/2021 11:40 AM   872
	Utility for uploading to NM Server if needed
	placed in crontab at 30 22 * * *
	This may catch files that failed to upload earlier in the day 
	if the local network or server were down

move_to_RMS.sh	 	6/5/2021  6:41 AM  1249
	A utility Steve Kaufman uses

README.md	 	7/24/2021 12:29 PM   598
	this github reference file

RecordWatchdog.sh	 7/26/2021  4:47 PM  8441
	RecordWatchdog, started by a crontab entry that
	runs StartCaptureWatchdog.sh

RMS_Restart.sh		 7/24/2021 12:28 PM   457
	Utility Pete uses on his Mint 20.2 test station

StartCaptureWatchdog.sh	 7/9/2021  4:02 PM  2728
	Runs from crontab entry at 30 22 * * *
	This runs WriteCapture.py and RecordWatchdog.sh

TimeLapse.sh		 7/9/2021 11:42 AM  10244
	Does error checking, creates TimeLapse.mp4 and Capture stack
	called by ExternalScript.py

Turn_Features_On_Off.txt 7/16/2021  9:26 AM  4589
	Slightly out of date summary of places to make changes for
	customized stations

update.sh		 7/10/2021  1:20 PM  1473
	Pete's utility that helps to automate code updates to our stations.

WriteCapture.py		 7/23/2021  2:53 PM  3309
	Writes the CaptureTimes.log file used by RecordWatchdog.sh
	and error checking in TimeLapse.sh

WriteCapture.sh		 7/24/2021 11:36 AM  1697
	Runs from crontab entry at 30 22 * * *
	This is used on our Buster RMS stations, since they are not
	currently running RecordWatchdog.sh.

NMMA RMS_data directories contain these extra directories:
ArchivedFilesReprocessed
ConfirmedFiles
csv
My_Uploads  (on two stations)
_______________
