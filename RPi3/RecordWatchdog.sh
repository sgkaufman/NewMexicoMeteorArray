#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Last Revision: 17-Jan-2023; Byte count: 8780
# RMS_RecordWatchdog.sh, version 0.2, Steve Kaufman and Pete Eschman
#
# This file belongs in directory $HOME/source/NMMA.
# It is intended to be started at boot on Jessie stations.
# It is not needed on Buster since FFMPEG replaced GStreamer.
# On Jessie, it is started by an entry in the autostart file 
# /home/pi/.config/lxsession/LXDE-pi/autostart
# Add these lines after "sudo service openvpn restart" 
#
#    Start the watchdog. 
#    /home/pi/source/NMMA/StartCaptureWatchdog.sh
#
# Dependencies:
# 1. ~/source/NMMA/StartRecordCapture.sh
# 2. ~/source/NMMA/WriteCapture.py

# This file tracks the creation of FITS files in the directory
# $HOME/RMS_data/CapturedFiles. If too long elapses between
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
#	a. Get current time
#	b. Check most recent FITS file, and its modification time
#	      Is FITS modification time > $wait_sec since current time?
#	      (Yes) Restart Capture
#	      (No)  Wait $wait_sec seconds, continue step 4 loop.

### NOTE ON printf: When printf is used in this script,
### it is called as "env printf". This guarantees that
### the documented GNU printf ("info printf" for documentation) is used.

# Variables
declare capture_dir="$HOME""/RMS_data/CapturedFiles"
declare log_dir="$HOME""/RMS_data/logs"
declare capture_file start_date
declare -i start_time capture_len capture_end
declare -i file_time now delta
declare -i wait_sec
declare -i new_log_count log_count
declare -i loop_count restart_count
declare -i log_level

log_level=0

# Read the $wait_sec argument

wait_sec=$1
echo "wait_sec = " "$wait_sec"

# Switch to the ~/source/RMS directory so relative path references,
# and python -m calls, work. Required at the top of the loop as
# this code changes directories further down.
cd "$HOME""/source/RMS"

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
echo '  for an estimated total fits file count of ' $(( $capture_len * 100 / 1024 ))

# capture_end is reduced by 15 minutes (900 seconds)
# because RMS will not restart capture if it is restarted with 15 or
# fewer minutes before capture is scheduled to end.
# So there is no point restarting in this time period.
capture_end=$((start_time + capture_len - 900))
env printf "Watchdog stop time, seconds: %d\n" "$capture_end"
capture_end_iso=$(date --date='@'"$capture_end")
echo 'Watchdog stop time ' "$capture_end_iso"

# Step 2: Check time now vs start time.
# Sometimes the watchdog will be started BY the watchdog rebooting the Pi.
# We must be sure that RMS has had time to get started, before we look
# for the RMS-created CapturedFiles in RecordWatchdog.sh.
# We will wait for 10 minutes since boot time in that case.

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

restart_count=0

### Step 3: Capture loop
while [ $now -lt $capture_end ]; do

    cd $capture_dir

    # Establish the time
    now=$(date +%s)

    # Find the most recent CapturedFiles directory

    ds=$(ls -tl --time-style="+%Y %m %d %H %M %S" | sed -n 2p)
    dir=$(echo $ds | cut -d' ' -f12)
    if [ $log_level -gt 0 ];
    then
	echo $dir
    fi
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
    file_time=$(echo $base_string | cut -d' ' -f6)
    if [ $log_level -gt 0 ];
    then
	echo $filename
	echo
    fi
	
    # Has it been too long since a FITS file was created?
    delta=$((now - file_time))
    if [ $log_level -gt 0 ];
    then
	env printf "file time delta = %d\n" $delta
    fi

    if [ $delta -gt $wait_sec ];
    then
	# Capture has failed
	restart_count=$(( restart_count + 1 ))
	timeUTC=$(date --date="@$now" +%H:%M:%S)
	fileUTC=$(date --date="@$file_time" +%H:%M:%S)
	env printf "Capture failure # %d \n" $restart_count
	env printf "last fits file created %s, current time %s, time delta = %d\n"\ 
	    $fileUTC $timeUTC $delta
	# write message to /var/log/syslog
	sudo logger 'record watchdog triggered'
	# killall python
	# Restart RMS, taking care not to kill other python apps or the watchdog
	ps -ef | grep RMS_ | egrep -v "atch|data|grep" | awk '{print $2}' | while read i
	     do
		  kill $i
	     done

	# reboot camera next

        cd "$HOME""/source/RMS"
	source "$HOME""/vRMS/bin/activate"

	python -m Utils.CameraControl reboot
	env sleep 5

	lxterminal -e Scripts/RMS_StartCapture.sh -r

	# Wait for a new log file to be created
	log_count=$(ls "$HOME"/RMS_data/logs/log*.log | wc -l)
	new_log_count=0
	loop_count=0
	while [ $new_log_count -le $log_count ]
	do
	    new_log_count=$(ls "$HOME"/RMS_data/logs/log*.log | wc -l)
	    loop_count=$(( loop_count + 1 ))
	    timenow=$(date +%H:%M:%S)
	    env printf "%s loop: %d, new_log_count: %d, waiting for new log file...\n" \
		$timenow $loop_count $new_log_count
	    if [ $loop_count -gt 3 ]; then
		# reboot
		env printf "Rebooting now...\n"
		sudo reboot now
	    fi
	    env sleep 60
	done

	# Wait for camera frame grabbing and any other restart overhead
	env sleep $wait_sec

	# Wait longer if the processing queue is still reloading
	loop_count=0
	while [ -f "$HOME"/RMS_data/.capture_resuming ] ;
	do
	    timenow=$(date +%H:%M:%S)
	    env printf "%s loop: %d, waiting for .capture_resuming flag...\n" \
		$timenow $loop_count
	    env sleep $wait_sec
	    loop_count=$(( loop_count + 1 ))
	done
	timenow=$(date +%H:%M:%S)
	env printf "%s Record Watchdog watching for new fits files now...\n\n" \
		$timenow
	# end of restart actions

    else
	# No problem detected - wait for another $wait_sec interval
	env sleep $wait_sec
    fi
done

env printf "Capture failure occured %d times last night\n" $restart_count
env printf "Recording watchdog finished for the night, time is "
date

exit 0
