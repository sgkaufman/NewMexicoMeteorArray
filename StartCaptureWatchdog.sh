#!/bin/bash

# Date: 21-May-2021; Byte count: 2403
# Starts the RecordWatchdog.sh monitoring program
# (to restart RMS if capture stops).

# Variable definitions
declare log_dir="/home/pi/RMS_data/logs"
declare system_os
declare -i wait_sec
declare latitude longitude elevation

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
    
# Step 1: Find ephemeris sunset time and capture time.
# Requires latitude, longitude, and elevation from the .config file
# The 3rd 'grep' is used to ensure that only 1 value comes back,
# even if there are multiple values (e.g., commented out in .config)
latitude=$(sed -n '/^latitude/'p .config | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
longitude=$(sed -n '/^longitude/'p .config | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
elevation=$(sed -n '/^elevation/'p .config | grep -Eo '[+-]?[0-9]+(\.[0-9]+)?' | grep -Eo -m 1 '[+-]?[0-9]+(\.[0-9]+)?')

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

capture_file=$(ls -lt $log_dir/"CaptureTimes"* | sed -n 1p | cut -d' ' -f10)
echo $capture_file

if [[ -f $capture_file ]]; then
	read time < $capture_file
	mo=$(date --date="$time" +%m)
	day=$(date --date="$time" +%d)
	yr=$(date --date="$time" +%Y)
else
	mo=$(date +'%m')
	day=$(date +'%d')
	yr=$(date +'%Y')
fi

log_file=$log_dir/"RMS_RecordWatchdog_"$mo"_"$day"_"$yr".log"

cd /home/pi/source/RMS/Scripts
echo Logging RMS_StartWatchdog.sh to $log_file ...
./RecordWatchdog.sh $wait_sec >> $log_file &
exit 0
