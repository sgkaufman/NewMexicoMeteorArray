#!/bin/bash

# Last Revision: 02-May-2021; Byte count: 8211
# 07/09/2020: Added "-r" option to Scripts/RMS_StartCapture.sh,
# and call to logger, like the kern.log watchdog.
# RMS_RecordWatchdog.sh, version 0.1, Steve Kaufman
# This file belongs in directory /home/pi/source/RMS/Scripts.
# It is intended to be started at boot (/etc/xdg/lxsession/LXDE-pi/autostart).

# This file tracks the creation of files in the directory
# /home/pi/RMS_data/CapturedFiles. If too long elapses between
# the creation of FITS files, a notification is made.
# The notification indicates that the capture process has stopped.
# The interval between invocations is the interval judged to be
# "too long" between the creation of FITS files.

# Here is the outline of the algorithm. It is an infinite loop,
# with these major steps:
# Step 1: Find ephemeris capture_start time,
# 	capture duration, and current time.
# Step 2: Is current time < capture_start time? 
#	Step 2a (Yes) sleep until capture_start time. Go to Step 3.
#	Step 2b (No) continue to Step 3.
# Step 3: Loop until end of capture time, every 3 minutes:
#       a. Get current time
#	b. Check most recent FITS file, and its modification time
#             Is FITS modification time > 3 minutes since current time?
#             (Yes) Restart Capture 
#	      (No) Continue
#	      Repeat Step 3.

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
declare capture_file start_date capture_float
declare system_os
declare -i start_time capture_len capture_end
declare -i file_time now delta
declare -i wait_sec

time_from_file () {
    # Given a fits file, determines its creation time in seonds from epoch.
    # Arguments are the directory name (under CapturedFiles) and file name.
    # This function assumes the RMS log directory file naming convention:
    # %Y%m%d_%H%M%S.%f which in human reads as
    # YYYYMMDD-HHMMSS.mmmmmm.log (m for microseconds).
    # Return value is created in the "echo" statement at the end.

    local hour day yr mo dt hr mn sec
    #printf "In time_from_file: 1st arg is %s, 2nd arg is %s\n" $1 $2

    if [ ! -e $capture_dir/$1/$2 ];
    then
	return 1
    fi
    
    # Extract the date field from the filename
    day="$(echo $filename | cut -d'_' -f3)"

    # Extract the time field from the filename
    hour="$(echo $filename | cut -d'_' -f4)"

    # Extract components of each
    yr=${day:0:4}
    mo=${day:4:2}
    dt=${day:6:2}
    hr=${hour:0:2}
    mn=${hour:2:2}
    sec=${hour:4:2}

    # Create strings suitable for the date parameter to date command.
    # First the day, with a trailing space
    ds=$yr-$mo-$dt" "
    # Second the time string
    hs=$hr:$mn:$sec

    # printf "date string = %s\n" $ds 
    #printf "hour string = %s\n" $hs

    # Convert the date and hour string into integer time
    last_fits_time=$(date --date="${ds} ${hs}" +%s)

    echo $last_fits_time
}

###################################################################
# Begin main watchdog

system_os=$( grep -Eo 'buster|jessie' /etc/os-release )
printf "system type: %s\n" "$system_os"
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
    esac
else
    echo "Raspbian OS neither buster nor jessie. Strange ..."
    exit 1
fi


# Switch to the ~/source/RMS directory so relative path references,
# and python -m calls, work. Required at the top of the loop as
# this code changes directories further down.
cd /home/pi/source/RMS
    
# Step 1: Find ephemeris sunset time and capture time.
# Requires latitude, longitude, and elevation from the .config file
latitude=$(sed -n '/^latitude/'p .config | egrep -o '[+-]?[0-9]+\.[0-9]+{4}')
longitude=$(sed -n '/^longitude/'p .config | egrep -o '[+-]?[0-9]+\.[0-9]+{4}')
elevation=$(sed -n '/^elevation/'p .config | egrep -o ' [+-]?[0-9]+(\.[0-9]+)? ')

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

capture_file=$(ls -t $log_dir/'CaptureTimes'* | sed -n 1p)
env printf "Using %s for start time and capture duration\n" $capture_file

# Read the start time and capture duration from the file
{
    read -r start_date
    capture_len=$(grep -Eo ^[0-9]+ -)
} < $capture_file

start_time=$(date --date="$start_date" +%s)
echo 'Start time, UTC: ' $start_date
echo Start time, seconds since epoch: $start_time
echo Capture length, seconds: $capture_len
    
# capture_end is reduced by 16.67 minutes (1000 seconds)
# because RMS will not restart capture if it is restarted with 15 or 
# fewer minutes before capture is scheduled to end.
# So there is no point restarting in this time period.
capture_end=$(($start_time + $capture_len - 1000))
echo Watchdog stop time, seconds: $capture_end
capture_end_iso=$(date --date='@'$capture_end)
echo 'Watchdog stop time ' $capture_end_iso

# Step 2: Check time now vs start time
now=$(date +%s)
if [ $start_time -gt $now ]
then
    env printf 'Now it is %d seconds since epoch\n' "$now" # time is\n' $now  \
#	$(date --date=@$now)
    init_wait_time=$(($start_time-$now))
    echo "Initial wait time: " $init_wait_time
    env sleep $(($init_wait_time-100))
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
    printf "%d seconds to go ...\n" $(($start_time - $now))
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
	printf "%s is not a directory, exiting...\n" $dir
	exit 1
    fi

    # Change into the directory just found
    cd $dir

    # Sort the fits files by modification time, and grab the most recent.
    # First, be sure that fits files have been created.
    # Send the listing and any errors of "no files found" to the bit bucket.
    ls -tl *.fits &> /dev/null
    if [ $? -ne 0 ]  # Did ls fail?
    then
	echo 'No FITS file yet'
	env sleep 60
	continue
    fi

    # reset $now in case the above loop led to sleep
    now=$(date +%s)
    base_string=$(ls -tl *.fits | sed -n 1p)
    filename=$(echo $base_string | cut -d' ' -f9)
    echo $filename

    file_time=$(time_from_file $dir $filename)
	
    # Has it been too long since a FITS file was created?
    delta=$(($now - $file_time))
    printf "file time delta = %d\n" $delta
    if [ $delta -gt $wait_sec ];
    then
	# Capture has failed
	echo "Capture has failed..."
	env printf "last fits file created %d, current time %d, time delta = %d \n"\
	    $file_time $now $delta
	# write message to /var/log/syslog
	sudo logger 'record watchdog triggered'
	touch /home/pi/source/RMS/.crash
	killall python
        env sleep 2
        cd $HOME/source/RMS
	source $HOME/vRMS/bin/activate
        lxterminal -e Scripts/RMS_StartCapture.sh -r
    fi

    # Wait for the processing queue to be reloaded
    
    env sleep 180 # Hardwired at 3 minutes based on experience.

    while [ -f /home/pi/RMS_data/.capture_resuming ] ;
    do
       env sleep $wait_sec
    done
    env sleep $wait_sec
done

printf "Recording watchdog finished for the night, time is "
date

sleep 1000

cd /home/pi/source/RMS

python -m RMS.WriteCapture \
       --latitude $latitude \
       --longitude $longitude \
       --elevation $elevation

exit 0
