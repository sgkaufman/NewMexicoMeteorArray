#!/bin/bash

# Date: 08-Jan-2023; Byte count: 3143
# Starts the RecordWatchdog.sh monitoring program
# (to restart RMS if capture stops).

# Variable definitions
declare log_dir="$HOME""/RMS_data/logs"
declare config_file="$HOME""/source/RMS/.config"
declare system_os
declare -i wait_sec
declare latitude longitude elevation

sudo logger 'StartCaptureWatchdog.sh started'

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

if [[ "$system_os" = "jessie" ]]
   then
    
# Step 1: Find ephemeris sunset time and capture time.
# Requires latitude, longitude, and elevation from the .config file
# The 3rd 'grep' is used to ensure that only 1 value comes back,
# even if there are multiple values (e.g., commented out in .config)
       latitude=$(sed -n '/^latitude/'p "$config_file" \
		      | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' \
		      | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
       longitude=$(sed -n '/^longitude/'p "$config_file" \
		       | grep -Eo '[+-]?[0-9]+\.[0-9]+{4}' \
		       | grep -Eo -m 1 '^[+-]?[0-9]+\.[0-9]+{4}')
       elevation=$(sed -n '/^elevation/'p "$config_file" \
		       | grep -Eo '[+-]?[0-9]+(\.[0-9]+)?' \
		       | grep -Eo -m 1 '[+-]?[0-9]+(\.[0-9]+)?')

       if [ ! $elevation ]
       then
	   echo "Error parsing elevation in .config file - exiting ..."
	   exit 1
       fi

       echo "Latitude: " $latitude
       echo "Longitude: " $longitude
       echo "Elevation: " $elevation

       pushd "$HOME"/source/RMS
       source "$HOME"/vRMS/bin/activate
       popd
       pushd "$HOME"/source/NMMA
       python -m WriteCapture \
	      --latitude $latitude \
	      --longitude $longitude \
	      --elevation $elevation
       popd

# Find the latest CaptureTimes file just created in the log directory.

       capture_file=$(find $log_dir/"CaptureTimes"* -maxdepth 1 -mmin -10)
       echo $capture_file

       if [[ -f $capture_file ]]; then
	   printf "Reading capture file %s\n" $capture_file
	   read time < $capture_file
	   mo=$(date --date="$time" +%m)
	   day=$(date --date="$time" +%d)
	   yr=$(date --date="$time" +%Y)
       else
	   printf "Not reading a capture file\n"
	   mo=$(date +'%m')
	   day=$(date +'%d')
	   yr=$(date +'%Y')
       fi

       log_file=$log_dir/"RMS_RecordWatchdog_"$mo"_"$day"_"$yr".log"

       cd "$HOME"/source/NMMA
       echo Logging RecordWatchdog.sh to $log_file ...
       "$HOME"/source/NMMA/RecordWatchdog.sh $wait_sec >> $log_file &
else
    env printf "System type %s does not require the capture watchdog\n" \
	"$system_os"
fi # if [[ "$system_os" = "jessie" ]]

exit 0
