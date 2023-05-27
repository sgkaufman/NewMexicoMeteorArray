# New Mexico Meteor Array (NMMA) 26-May, 2023
Files for NMMA, a sub-network of the Global Meteor Network

# NMMA Functions implemented
## Post-processing for the New Mexico Meteor Array
- ExternalScript.py (Uploads some files to NM Server, calls the following two)
- TimeLapse.sh (creates TimeLapse mp4 movie, CaptureStack, and statistical diagnostic information)
- BackupToUSB.sh (Backs up some nightly date to an attached USB flash drive)

## Recording Watchdog. This watchdog restarts RMS if capture stops during the night.
- Only used on Jessie RMS stations. 
- StartCaptureWatchdog.sh
- RecordWatchdog.sh

## NMMA Utilities
All files should be located in ~/source/NMMA
04/14/2023  12:55 PM               887 Backup.sh
05/24/2023  01:59 PM             3,415 BackupToUSB.sh
04/15/2021  10:11 AM             1,239 CamSet.sh
07/31/2022  08:51 AM             1,551 Chk_Website.sh
05/26/2023  10:13 AM             7,924 ErrorCheck.sh
05/22/2023  12:59 PM            12,303 ExternalScript.py
12/21/2022  02:18 PM             3,233 FixIt.sh
01/26/2023  02:10 PM             1,474 FlushNMqueue.py
01/17/2023  11:01 AM               866 FlushNMqueue.sh
05/27/2023  04:47 AM             3,581 README.md
01/17/2023  10:25 AM             8,780 RecordWatchdog.sh
01/08/2023  02:22 PM             3,143 StartCaptureWatchdog.sh
03/12/2023  10:12 AM            11,002 TimeLapse.sh
05/27/2023  04:45 PM             2,450 Turn_Features_On_Off.txt
01/17/2023  11:11 AM             3,284 WriteCapture.py
01/25/2023  11:23 AM             1,829 WriteCapture.sh

01/19/2023  08:15 PM    <DIR>          GUI_Linux
01/20/2023  11:29 AM    <DIR>          iStreamNM
01/19/2023  08:04 PM    <DIR>          Older
01/20/2023  10:12 AM    <DIR>          RPi3

Backup.sh
	Creates reference copy of important microSD card files

BackupToUSB.sh
	Backup data every morning to thumb drive, delete old files
	called by ExternalScript.py

CamSet.sh
	Utility for switching camera between nighttime & daytime modes

Chk_Website.sh
	Optional website status monitor

ExternalScript.py
	NMMA ExternalScript.py
	Calls ErrorCheck.sh and BackupToUSB.sh
	If My_Uploads.sh is found will be used to copy station files 
	to a station owner's web site. Calls TimeLapse.sh, and My_Uploads.sh

FixIt.sh
	Utility for processing missing data: runs a reprocess job followed by
	ExternalScript.py

FlushNMqueue.py
	Utility for uploading to NM Server if needed

FlushNMqueue.sh
	Utility for uploading to NM Server if needed
	placed in crontab at 30 22 * * *
	This may catch files that failed to upload earlier in the day 
	if the local network or server were down

README.md
	this github reference file

RecordWatchdog.sh (located in git RPi3 subdirectory)
	Used only on Jessie RMS

StartCaptureWatchdog.sh (located in git RPi3 subdirectory)
	Used only on Jessie RMS
	This runs WriteCapture.py and RecordWatchdog.sh

ErrorChecksh
	Does error checking
	called by ExternalScript.py

Turn_Features_On_Off.txt
	Slightly out of date summary of places to make changes for
	customized stations

WriteCapture.py
	Writes ~/RMS_data/logs/CaptureTimes.log
	used by RecordWatchdog.sh and error checking in TimeLapse.sh

WriteCapture.sh
	Not used on Jessie RMS
	Calls WriteCapture.py
	Runs from crontab entry at 30 22 * * *


## File System Structure
NMMA RMS_data directories contain these extra directories:
 ArchivedFilesReprocessed
 ConfirmedFiles
 csv
 My_Uploads  (on several stations that do custom uploads to user's website)
__________
