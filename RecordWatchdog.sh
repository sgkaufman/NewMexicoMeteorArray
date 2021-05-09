#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Last Revision: 09-May-2021; Byte count: 9297
# RMS_RecordWatchdog.sh, version 0.1, Steve Kaufman and Pete Eschman
# This file belongs in directory /home/pi/source/RMS/Scripts.
# It is intended to be started at boot
# (Buster: /etc/xdg/lxsession/LXDE-pi/autostart
#  Jessie: /home/pi/.config/lxsession/LXDE-pi/autostart).
# Dependencies: 
# 1. ~/source/RMS/StartRecordCapture.sh
# 2. ~/source/RMS/RMS/WriteCapture.py

# This file tracks the creation of FITS files in the directory
# /home/pi/RMS_data/CapturedFiles. If too long elapses between
# the creation of FITS files, the RMS system is restarted.
# "Too long" is defined in the variable $wait_sec

# Here is the outline of the algorithm. 
# with these major steps:
# Step 1: Identify system type, set $wait_sec appropriately.
# Step 2: Find ephemeris capture_start time,
# 	capture duration, and current time.
# Step 3: Is current time < capture_start time? 
#	Step 3a (Yes) sleep until capture_start time. Go to Step 4.
#	Step 3b (No) continue to Step 4.
# Step 4: Loop until end of capture time, every $wait_sec interval
#       a. Get current time
#	b. Check most recent FITS file, and its modification time
#             Is FITS modification time > $wait_sec since current time?
#             (Yes) Restart Capture
#	      (No)  Wait $wait_sec seconds, continue step 4 loop.

### NOTE ON printf: When printf is used in this script,
### it is called as "env printf". Using the env command first guarantees
### that the documented GNU printf ("info printf" for documentation)
### is used. I've had odd results using the bare "printf".
### You can see the difference by typing "printf --version"
### and "env printf --version" at the shell prompt.
### Not every RMS station necessarily has this issue, but the author's does.
### I do the same with the "sleep" function, although there does not
### seem to be any difference on my Buster and Jessie stations
### at the time of this writing.

# Variables
declare capture_dir=$HOME/RMS_data/CapturedFiles
declare log_dir=$HOME/RMS_data/logs
declare latitude longitude elevation
declare capture_file start_date
declare system_os
declare -i start_time capture_len capture_end
declare -i file_time now delta
declare -i wait_sec
declare -i new_log_count log_count
declare -i loop_count

# System identification

if [[ -f /etc/os-release ]]; then
    system_os=$( grep -Eo 'buster|jessie' /etc/os-release )

    if [[ -n "$system_os" ]]; then
	case ${system_os:0:6} in
	    buster )
		wait_sec=120
		system_os="buster"
		;;
	    jessie )
		wait_sec=180
		system_os="jessie"
		;;
	    *      )
		wait_sec=120
		system_os=${system_os:0:6}
		;;
	esac
	env printf "System type: %s\n" "$system_os"
    else
	echo "OS neither buster nor jessie. Forging ahead ... "
    fi
else
    env printf "No file /etc/os-release to identify system type. Forging ahead ...\n"
    wait_sec=120
    system_os="unknown"
fi

# Switch to the ~/source/RMS directory so relative path references,
# and python -m calls, work. Required at the top of the loop as
# this code changes directories further down.
cd /home/pi/source/RMS
    
# Step 1: Find ephemeris sunset time and capture time.
# Requires latitude, longitude, and elevation from the .config file
latitude=$(sed -n '/^latitude/'p .config | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}')
longitude=$(sed -n '/^longitude/'p .config | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}')
elevation=$(sed -n '/^elevation/'p .config | grep -Eo ' [+-]?[0-9]+(\.[0-9]+)? ')

if [ ! $elevation ]
then
    echo "Error parsing elevation in .config file - exiting ..."
    exit 1
fi

echo "Latitude: " $latitude
echo "Longitude: " $longitude
echo "Elevation: " $elevation

python -m RMS.WriteCapture \
       --latitude $latitude \
       --longitude $longitude \
       --elevation $elevation

# Find the latest CaptureTimes file in the log directory

capture_file=$(ls -t $log_dir/"CaptureTimes"* | sed -n 1p)

env printf "Using %s for start time and capture duration\n" $capture_file

# Read the start time and capture duration from the file
{
    read -r start_date
    capture_len=$(grep -Eo '^[0-9]+' -)
} < $capture_file

start_time=$(date --date="$start_date" +%s)
echo 'Start time, UTC: ' $start_date
echo Start time, seconds since epoch: $start_time
echo Capture length, seconds: $capture_len
    
# capture_end is reduced by 15 minutes (900 seconds)
# because RMS will not restart capture if it is restarted with 15 or 
# fewer minutes before capture is scheduled to end.
# So there is no point restarting in this time period.
capture_end=$((start_time + capture_len - 900))
env printf "Watchdog stop time, seconds: %d\n" "$capture_end"
capture_end_iso=$(date --date='@'"$capture_end")
echo 'Watchdog stop time ' "$capture_end_iso"

# Step 2: Check time now vs start time
now=$(date +%s)
now_iso=$(date --date='@'"$now")
if [ $start_time -gt $now ]
then
    env printf 'Now it is %d seconds since epoch' "$now"
    env printf "\t($now_iso)\n"
    init_wait_time=$((start_time - now))
    echo "Initial wait time: " $init_wait_time
    env sleep $((init_wait_time - 100))
fi

### Wait until it's time for capture. The wait interval is 1/3 the interval
### during capture time to avoid the following situation:
### 1. We go into a wait just before the capture time begins (e.g., 0.25 sec).
### 2. When capture begins the first file is created.
### 3. By the time this watchdog checks, the full wait time has elapsed.
### 4. So the capture process is restarted because this watchdog was too eager.

#### Just in case sleep ended too soon ...
now=$(date +%s)
while [ $now -lt $start_time ]; do
    env sleep $((wait_sec/3))
    now=$(date +%s)
    env printf "%d seconds to go ...\n" $((start_time - now))
done

### Step 3: Capture loop
while [ $now -lt $capture_end ]; do

    cd $capture_dir    
    
    # Establish the time
    now=$(date +%s)

    # Find the most recent CapturedFiles directory
    
    ds=$(ls -tl --time-style="+%Y %m %d %H %M %S" | sed -n 2p)
    dir=$(echo $ds | cut -d' ' -f12)
    echo $dir
    if [ ! -d $dir ];
    then 
	env printf "%s is not a directory, exiting...\n" $dir
	exit 1
    fi

    # Change into the directory just found
    cd $dir

    # Sort the fits files by modification time, and grab the most recent.
    # First, be sure that fits files have been created.
    # Send the listing and any errors of "no files found" to the bit bucket.
    ls -tl ./*.fits &> /dev/null
    if [ $? -ne 0 ]  # Did ls fail?
    then
	echo 'No FITS file yet'
	env sleep 60
	continue
    fi

    # reset $now in case the above loop led to sleep
    now=$(date +%s)
    base_string=$(ls -tl --time-style="+%s" -- *.fits | sed -n 1p)
    filename=$(echo $base_string | cut -d' ' -f7)
    echo $filename
    file_time=$(echo $base_string | cut -d' ' -f6)
    echo 
	
    # Has it been too long since a FITS file was created?
    delta=$((now - file_time))
    env printf "file time delta = %d\n" $delta
    if [ $delta -gt $wait_sec ];
    then
	# Capture has failed
	echo "Capture has failed..."
	env printf "last fits file created %d, current time %d, time delta = %d \n"\
	    $file_time $now $delta
	# write message to /var/log/syslog
	sudo logger 'record watchdog triggered'
	killall python
        env sleep 2
        cd $HOME/source/RMS
	source $HOME/vRMS/bin/activate
        lxterminal -e Scripts/RMS_StartCapture.sh -r

	# Wait for the processing queue to be reloaded
	# First we wait for a new log file to be created
	log_count=$(ls /home/pi/RMS_data/logs/log*.log | wc -l)
	new_log_count=0
	loop_count=0
	while [ $new_log_count -le $log_count ] 
	do
	    new_log_count=$(ls /home/pi/RMS_data/logs/log*.log | wc -l)
	    loop_count=$(( loop_count + 1 ))
	    timenow=$(date +%H:%M:%S)
	    env printf "%s loop: %d, new_log_count: %d, waiting for new log file...\n" \
		$timenow $loop_count $new_log_count
	    env sleep 60
	done

	# Wait for camera frame grabbing other other restart overhead
	env sleep $wait_sec 

	# Now wait for any processing of previous images to be completed
	loop_count=0
	while [ -f /home/pi/RMS_data/.capture_resuming ] ;
	do
	    timenow=$(date +%H:%M:%S)
	    env printf "%s loop: %d, waiting for .capture_resuming flag...\n" \
		$timenow $loop_count 
	    env sleep $wait_sec
	    loop_count=$(( loop_count + 1 ))
 	done
	# end of restart actions
    else
	# No problem detected - wait for another $wait_sec interval
	sleep $wait_sec
    fi
done

env printf "Recording watchdog finished for the night, time is "
date

sleep 900

cd /home/pi/source/RMS

python -m RMS.WriteCapture \
       --latitude $latitude \
       --longitude $longitude \
       --elevation $elevation

exit 0
